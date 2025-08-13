import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing.dart';
import '../services/supabase_service.dart';

class ListingsFilter {
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;
  final int? bathrooms;
  final int? minRating;

  const ListingsFilter({this.city, this.minPrice, this.maxPrice, this.bedrooms, this.bathrooms, this.minRating});
}

class ListingsRepository {
  Future<List<Listing>> fetchListings(ListingsFilter filter) async {
    var query = supabase.from('listings').select().eq('is_published', true).order('created_at', ascending: false);
    if (filter.city != null && filter.city!.isNotEmpty) {
      query = query.ilike('city', '%${filter.city!}%');
    }
    if (filter.minPrice != null) {
      query = query.gte('price_per_night', filter.minPrice);
    }
    if (filter.maxPrice != null) {
      query = query.lte('price_per_night', filter.maxPrice);
    }
    if (filter.bedrooms != null) {
      query = query.gte('bedrooms', filter.bedrooms);
    }
    if (filter.bathrooms != null) {
      query = query.gte('bathrooms', filter.bathrooms);
    }
    if (filter.minRating != null) {
      query = query.gte('average_rating', filter.minRating);
    }
    final result = await query;
    final list = (result as List).cast<Map<String, dynamic>>().map(Listing.fromMap).toList();
    return list;
  }
}

final listingsRepositoryProvider = Provider((ref) => ListingsRepository());
final listingsFilterProvider = StateProvider((ref) => const ListingsFilter());
final listingsFutureProvider = FutureProvider.autoDispose<List<Listing>>((ref) async {
  final repo = ref.watch(listingsRepositoryProvider);
  final filter = ref.watch(listingsFilterProvider);
  return repo.fetchListings(filter);
});