# GoDarna (Flutter + Supabase)

Airbnb-like Moroccan rentals app with passwordless OTP, COD payments, bilingual UI (Darija/Fr), and Supabase backend with RLS.

## Features
- Passwordless email OTP (Supabase Auth)
- Listings with filters (city, price, rooms, rating)
- Booking flow with Cash on Delivery (COD)
- Realtime updates (bookings)
- Reviews and average rating
- Bilingual UI (ar-MA, fr-FR), red visual identity
- RLS-secured tables and role-based access (tenant, host, admin)

## Prerequisites
- Flutter SDK (3.22+)
- A Supabase project (URL + anon key)

## Setup
1. Clone/open this repo.
2. Copy env file:
   ```bash
   cp .env.example .env
   ```
   Fill `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
3. Create Flutter platforms (if missing):
   ```bash
   flutter create .
   ```
4. Install deps:
   ```bash
   flutter pub get
   ```
5. Supabase: open `supabase/schema.sql` in the SQL editor, run all statements.
   - Ensure Realtime is enabled for `listings`, `bookings`, `reviews`.
   - Optional: Set some users to `host` or `admin` by updating `profiles.role`.
6. Run the app:
   ```bash
   flutter run
   ```

## OTP Notes
- The app uses email OTP (code). Supabase must have email provider enabled.
- Users enter email, request code, then verify.

## Cash on Delivery (COD)
- When COD is selected, the booking is created with `status=pending` and `payment_status=pending`.
- Host can confirm/cancel in future admin/host views; collection recorded in `payments` table.

## Realtime
- Bookings page subscribes to Supabase Realtime to reflect changes instantly.

## i18n
- Texts are in `