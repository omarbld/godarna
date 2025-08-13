import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../services/supabase_service.dart';

class BookingsRepository {
  Future<List<Booking>> fetchMyBookings(String userId) async {
    final result = await supabase
        .from('bookings')
        .select()
        .eq('tenant_id', userId)
        .order('created_at', ascending: false);
    final list = (result as List).cast<Map<String, dynamic>>().map(Booking.fromMap).toList();
    return list;
  }

  Future<String> createBooking({
    required String tenantId,
    required String listingId,
    required DateTime startDate,
    required DateTime endDate,
    required int numGuests,
    required double totalPrice,
    required String paymentMethod, // cod | online
  }) async {
    final result = await supabase.from('bookings').insert({
      'tenant_id': tenantId,
      'listing_id': listingId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'num_guests': numGuests,
      'total_price': totalPrice,
      'status': 'pending',
      'payment_method': paymentMethod,
      'payment_status': paymentMethod == 'cod' ? 'pending' : 'unpaid',
    }).select('id').single();
    return result['id'] as String;
  }
}

final bookingsRepositoryProvider = Provider((ref) => BookingsRepository());
final myBookingsProvider = FutureProvider.family.autoDispose<List<Booking>, String>((ref, userId) async {
  final repo = ref.watch(bookingsRepositoryProvider);
  return repo.fetchMyBookings(userId);
});