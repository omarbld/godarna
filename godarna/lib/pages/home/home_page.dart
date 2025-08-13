import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/listing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../filters/filters_sheet.dart';
import 'widgets/listing_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(listingsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('home.title')),
        actions: [
          IconButton(
            onPressed: () => context.push('/bookings'),
            icon: const Icon(Icons.event_note),
            tooltip: tr('home.my_bookings'),
          ),
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person),
            tooltip: tr('home.profile'),
          ),
        ],
      ),
      floatingActionButton: _HostFAB(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: tr('home.search_hint'),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onSubmitted: (value) {
                      ref.read(listingsFilterProvider.notifier).state =
                          ListingsFilter(city: value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () async {
                    final filter = await showModalBottomSheet<ListingsFilter>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const FiltersSheet(),
                    );
                    if (filter != null) {
                      ref.read(listingsFilterProvider.notifier).state = filter;
                    }
                  },
                  icon: const Icon(Icons.tune),
                  label: Text(tr('home.filters')),
                ),
              ],
            ),
          ),
          Expanded(
            child: listingsAsync.when(
              data: (items) => _ListingsGrid(items: items),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }
}

class _HostFAB extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isHostOrAdmin = auth.profile?.role == 'host' || auth.profile?.role == 'admin';
    if (!isHostOrAdmin) return const SizedBox.shrink();
    return FloatingActionButton.extended(
      onPressed: () => context.push('/add-listing'),
      icon: const Icon(Icons.add_home_work),
      label: Text(tr('home.add_listing')),
    );
  }
}

class _ListingsGrid extends StatelessWidget {
  final List<Listing> items;
  const _ListingsGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text(tr('home.no_results')));
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => ListingCard(listing: items[index]),
    );
  }
}