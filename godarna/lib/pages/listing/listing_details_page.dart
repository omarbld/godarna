import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../models/listing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../services/supabase_service.dart';

class ListingDetailsPage extends ConsumerStatefulWidget {
  final String listingId;
  const ListingDetailsPage({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailsPage> createState() => _ListingDetailsPageState();
}

class _ListingDetailsPageState extends ConsumerState<ListingDetailsPage> {
  Listing? listing;
  DateTimeRange? dateRange;
  int guests = 1;
  String paymentMethod = 'cod';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await supabase.from('listings').select().eq('id', widget.listingId).maybeSingle();
    if (result != null) {
      setState(() {
        listing = Listing.fromMap(result);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  double getTotalPrice() {
    if (listing == null || dateRange == null) return 0;
    final nights = dateRange!.duration.inDays;
    return listing!.pricePerNight * nights;
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text(tr('listing.details'))),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : listing == null
              ? Center(child: Text(tr('listing.not_found')))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImage(
                          imageUrl: listing!.mainImageUrl ?? 'https://picsum.photos/800?random=${listing!.id.hashCode % 1000}',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(listing!.title, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(listing!.description),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Chip(label: Text(tr('listing.bedrooms', args: [listing!.bedrooms.toString()]))),
                          const SizedBox(width: 8),
                          Chip(label: Text(tr('listing.bathrooms', args: [listing!.bathrooms.toString()]))),
                          const SizedBox(width: 8),
                          Chip(label: Text(tr('listing.max_guests', args: [listing!.maxGuests.toString()]))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('${tr('listing.price')}: ${listing!.pricePerNight.toStringAsFixed(0)} MAD / ${tr('listing.night')}'),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(dateRange == null
                            ? tr('booking.select_dates')
                            : '${DateFormat.yMMMd().format(dateRange!.start)} → ${DateFormat.yMMMd().format(dateRange!.end)}'),
                        trailing: const Icon(Icons.date_range),
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(now.year, now.month, now.day),
                            lastDate: DateTime(now.year + 1),
                          );
                          if (picked != null) setState(() => dateRange = picked);
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(tr('booking.guests')),
                              subtitle: Text(guests.toString()),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => guests = (guests - 1).clamp(1, 99)),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          IconButton(
                            onPressed: () => setState(() => guests = (guests + 1).clamp(1, listing!.maxGuests)),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(tr('payment.method')),
                      RadioListTile(
                        value: 'cod',
                        groupValue: paymentMethod,
                        onChanged: (v) => setState(() => paymentMethod = 'cod'),
                        title: Text(tr('payment.cod')),
                        subtitle: Text(tr('payment.cod_hint')),
                      ),
                      RadioListTile(
                        value: 'online',
                        groupValue: paymentMethod,
                        onChanged: (v) => setState(() => paymentMethod = 'online'),
                        title: Text(tr('payment.online')),
                        subtitle: Text(tr('payment.online_hint')),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (auth.profile == null) return;
                          if (dateRange == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('booking.select_dates_first'))));
                            return;
                          }
                          final total = getTotalPrice();
                          final id = await ref.read(bookingsRepositoryProvider).createBooking(
                                tenantId: auth.profile!.id,
                                listingId: listing!.id,
                                startDate: dateRange!.start,
                                endDate: dateRange!.end,
                                numGuests: guests,
                                totalPrice: total,
                                paymentMethod: paymentMethod,
                              );
                          if (paymentMethod == 'cod') {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('payment.cod_confirmed'))));
                          } else {
                            if (!mounted) return;
                            context.push('/payment?bookingId=$id');
                          }
                        },
                        child: Text('${tr('booking.book_now')} • ${getTotalPrice().toStringAsFixed(0)} MAD'),
                      ),
                    ],
                  ),
                ),
    );
  }
}