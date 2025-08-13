-- GoDarna Supabase schema
-- Run this in Supabase SQL editor or through migrations.

-- Enable required extensions
create extension if not exists "uuid-ossp";
create extension if not exists pgcrypto;

-- ENUMS
create type user_role as enum ('tenant', 'host', 'admin');
create type booking_status as enum ('pending', 'confirmed', 'cancelled', 'completed');
create type payment_method as enum ('cod', 'online');
create type payment_status as enum ('unpaid', 'paid', 'failed', 'refunded', 'pending');

-- PROFILES
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique,
  full_name text,
  avatar_url text,
  role user_role not null default 'tenant',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email);
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.touch_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- LISTINGS
create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  host_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  description text,
  price_per_night numeric not null check (price_per_night >= 0),
  bedrooms int not null default 1 check (bedrooms >= 0),
  bathrooms int not null default 1 check (bathrooms >= 0),
  max_guests int not null default 1 check (max_guests > 0),
  city text not null,
  address_line text,
  lat double precision,
  lng double precision,
  main_image_url text,
  is_published boolean not null default false,
  average_rating numeric,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger listings_touch_updated
before update on public.listings
for each row execute function public.touch_updated_at();

-- LISTING IMAGES
create table if not exists public.listing_images (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings(id) on delete cascade,
  image_url text not null,
  order_index int not null default 0,
  created_at timestamptz not null default now()
);

-- BOOKINGS
create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.profiles(id) on delete cascade,
  listing_id uuid not null references public.listings(id) on delete cascade,
  start_date date not null,
  end_date date not null,
  num_guests int not null check (num_guests > 0),
  total_price numeric not null check (total_price >= 0),
  status booking_status not null default 'pending',
  payment_method payment_method not null default 'cod',
  payment_status payment_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint valid_date_range check (end_date > start_date)
);

create trigger bookings_touch_updated
before update on public.bookings
for each row execute function public.touch_updated_at();

-- Prevent overlapping confirmed/pending bookings for the same listing
create or replace function public.prevent_overlapping_bookings()
returns trigger as $$
begin
  if exists (
    select 1 from public.bookings b
    where b.listing_id = new.listing_id
      and b.id <> coalesce(new.id, '00000000-0000-0000-0000-000000000000')
      and daterange(b.start_date, b.end_date, '[]') && daterange(new.start_date, new.end_date, '[]')
      and b.status in ('pending','confirmed')
  ) then
    raise exception 'Overlapping booking exists for this listing';
  end if;
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_prevent_overlap on public.bookings;
create trigger trg_prevent_overlap
  before insert or update on public.bookings
  for each row execute function public.prevent_overlapping_bookings();

-- PAYMENTS (records for audit)
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  method payment_method not null,
  status payment_status not null,
  amount numeric not null check (amount >= 0),
  transaction_ref text,
  created_at timestamptz not null default now()
);

-- REVIEWS
create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  listing_id uuid not null references public.listings(id) on delete cascade,
  tenant_id uuid not null references public.profiles(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now()
);

-- FAVORITES
create table if not exists public.favorites (
  tenant_id uuid not null references public.profiles(id) on delete cascade,
  listing_id uuid not null references public.listings(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (tenant_id, listing_id)
);

-- Aggregate rating update
create or replace function public.update_average_rating()
returns trigger as $$
begin
  update public.listings l
  set average_rating = sub.avg_rating,
      updated_at = now()
  from (
    select listing_id, avg(rating)::numeric as avg_rating
    from public.reviews
    where listing_id = new.listing_id
    group by listing_id
  ) sub
  where l.id = sub.listing_id;
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_update_avg_rating on public.reviews;
create trigger trg_update_avg_rating
  after insert or update or delete on public.reviews
  for each row execute function public.update_average_rating();

-- RLS
alter table public.profiles enable row level security;
alter table public.listings enable row level security;
alter table public.listing_images enable row level security;
alter table public.bookings enable row level security;
alter table public.payments enable row level security;
alter table public.reviews enable row level security;
alter table public.favorites enable row level security;

-- Helper: check if user is admin
create or replace function public.is_admin(uid uuid)
returns boolean as $$
  select exists(select 1 from public.profiles p where p.id = uid and p.role = 'admin');
$$ language sql stable;

-- PROFILES policies
create policy "Public read own profile" on public.profiles for select
  using (auth.uid() = id or public.is_admin(auth.uid()));

create policy "Users update own profile" on public.profiles for update
  using (auth.uid() = id) with check (auth.uid() = id);

-- LISTINGS policies
create policy "Anyone can view published listings" on public.listings for select
  using (is_published = true);

create policy "Host view own listings" on public.listings for select
  using (auth.uid() = host_id);

create policy "Host insert own listing" on public.listings for insert
  with check (auth.uid() = host_id);

create policy "Host update own listing" on public.listings for update
  using (auth.uid() = host_id) with check (auth.uid() = host_id);

create policy "Admin full access listings" on public.listings for all
  using (public.is_admin(auth.uid()));

-- LISTING_IMAGES policies
create policy "Public view images of published listings" on public.listing_images for select
  using (exists (select 1 from public.listings l where l.id = listing_id and (l.is_published = true or l.host_id = auth.uid()) ) );

create policy "Host manage images of own listings" on public.listing_images for all
  using (exists (select 1 from public.listings l where l.id = listing_id and l.host_id = auth.uid()))
  with check (exists (select 1 from public.listings l where l.id = listing_id and l.host_id = auth.uid()));

-- BOOKINGS policies
create policy "Tenant read own bookings" on public.bookings for select
  using (tenant_id = auth.uid() or exists (select 1 from public.listings l where l.id = listing_id and l.host_id = auth.uid()) or public.is_admin(auth.uid()));

create policy "Tenant create own bookings" on public.bookings for insert
  with check (tenant_id = auth.uid());

create policy "Tenant update own bookings (cancel)" on public.bookings for update
  using (tenant_id = auth.uid()) with check (tenant_id = auth.uid());

create policy "Host update status for listings they own" on public.bookings for update
  using (exists (select 1 from public.listings l where l.id = listing_id and l.host_id = auth.uid()))
  with check (true);

create policy "Admin full access bookings" on public.bookings for all
  using (public.is_admin(auth.uid()));

-- PAYMENTS policies
create policy "Tenant/Host/Admin read related payments" on public.payments for select
  using (
    exists (
      select 1 from public.bookings b
      join public.listings l on l.id = b.listing_id
      where b.id = booking_id and (
        b.tenant_id = auth.uid() or l.host_id = auth.uid() or public.is_admin(auth.uid())
      )
    )
  );
create policy "Insert payment by admin or host for COD collection" on public.payments for insert
  with check (
    public.is_admin(auth.uid()) or exists (
      select 1 from public.bookings b join public.listings l on l.id = b.listing_id
      where b.id = booking_id and l.host_id = auth.uid()
    )
  );

-- REVIEWS policies
create policy "Public read reviews of published listings" on public.reviews for select
  using (exists (select 1 from public.listings l where l.id = listing_id and l.is_published = true));

create policy "Tenant insert review only if booking completed" on public.reviews for insert
  with check (
    tenant_id = auth.uid() and exists (
      select 1 from public.bookings b where b.id = booking_id and b.tenant_id = auth.uid() and b.status = 'completed'
    )
  );

-- FAVORITES policies
create policy "Tenant manage own favorites" on public.favorites for all
  using (tenant_id = auth.uid()) with check (tenant_id = auth.uid());

-- STORAGE bucket for listing images
insert into storage.buckets (id, name, public) values ('listing-images', 'listing-images', true)
  on conflict (id) do nothing;

-- Storage policies
create policy "Public read listing images" on storage.objects for select
  using (bucket_id = 'listing-images');

create policy "Host upload to listing images" on storage.objects for insert
  with check (bucket_id = 'listing-images');

-- Realtime replication hints: ensure Realtime is enabled for tables in Supabase dashboard
-- Suggested: listings, bookings, reviews

-- INDEXES for performance
create index if not exists idx_listings_city on public.listings using gin (to_tsvector('simple', city));
create index if not exists idx_listings_price on public.listings (price_per_night);
create index if not exists idx_bookings_listing on public.bookings (listing_id);
create index if not exists idx_bookings_tenant on public.bookings (tenant_id);