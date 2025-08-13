import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:godarna/models/booking_model.dart';

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all bookings (for admin)
  Future<List<BookingModel>> getBookings() async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .order('created_at', ascending: false);

      if (response != null) {
        return (response as List)
            .map((json) => BookingModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get bookings: $e');
    }
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('id', bookingId)
          .single();

      if (response != null) {
        return BookingModel.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  // Get bookings by tenant
  Future<List<BookingModel>> getBookingsByTenant(String tenantId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('tenant_id', tenantId)
          .order('created_at', ascending: false);

      if (response != null) {
        return (response as List)
            .map((json) => BookingModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get tenant bookings: $e');
    }
  }

  // Get bookings by host
  Future<List<BookingModel>> getBookingsByHost(String hostId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('host_id', hostId)
          .order('created_at', ascending: false);

      if (response != null) {
        return (response as List)
            .map((json) => BookingModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get host bookings: $e');
    }
  }

  // Create new booking
  Future<BookingModel?> createBooking({
    required String propertyId,
    required String tenantId,
    required String hostId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int nights,
    required double totalPrice,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final bookingData = {
        'property_id': propertyId,
        'tenant_id': tenantId,
        'host_id': hostId,
        'check_in': checkIn.toIso8601String(),
        'check_out': checkOut.toIso8601String(),
        'nights': nights,
        'total_price': totalPrice,
        'status': 'pending',
        'payment_method': paymentMethod,
        'payment_status': 'pending',
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('bookings')
          .insert(bookingData)
          .select()
          .single();

      if (response != null) {
        return BookingModel.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);
      
      return true;
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Update payment status
  Future<bool> updatePaymentStatus(String bookingId, String paymentStatus) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'payment_status': paymentStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);
      
      return true;
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // Add review and rating
  Future<bool> addReview({
    required String bookingId,
    required double rating,
    required String review,
  }) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'rating': rating,
            'review': review,
            'review_date': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);
      
      // Update property rating
      await _updatePropertyRating(bookingId, rating);
      
      return true;
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // Update property rating when review is added
  Future<void> _updatePropertyRating(String bookingId, double rating) async {
    try {
      // Get the booking to find the property
      final booking = await getBookingById(bookingId);
      if (booking != null) {
        // Get current property rating
        final propertyResponse = await _supabase
            .from('properties')
            .select('rating, review_count')
            .eq('id', booking.propertyId)
            .single();

        if (propertyResponse != null) {
          final currentRating = propertyResponse['rating'] as num? ?? 0.0;
          final currentReviewCount = propertyResponse['review_count'] as int? ?? 0;
          
          // Calculate new average rating
          final newRating = ((currentRating * currentReviewCount) + rating) / (currentReviewCount + 1);
          final newReviewCount = currentReviewCount + 1;
          
          // Update property rating
          await _supabase
              .from('properties')
              .update({
                'rating': newRating,
                'review_count': newReviewCount,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', booking.propertyId);
        }
      }
    } catch (e) {
      // Handle error silently for rating update
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);
      
      return true;
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Get booking statistics
  Future<Map<String, dynamic>> getBookingStats() async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('status, payment_status, total_price, created_at');

      if (response != null) {
        final bookings = response as List;
        
        final totalBookings = bookings.length;
        final pendingBookings = bookings.where((b) => b['status'] == 'pending').length;
        final confirmedBookings = bookings.where((b) => b['status'] == 'confirmed').length;
        final completedBookings = bookings.where((b) => b['status'] == 'completed').length;
        final cancelledBookings = bookings.where((b) => b['status'] == 'cancelled').length;
        
        final totalRevenue = bookings
            .where((b) => b['payment_status'] == 'paid')
            .fold<double>(0.0, (sum, b) => sum + (b['total_price'] as num));
        
        // Monthly revenue
        final now = DateTime.now();
        final currentMonth = now.month;
        final currentYear = now.year;
        
        final monthlyRevenue = bookings
            .where((b) {
              final bookingDate = DateTime.parse(b['created_at']);
              return b['payment_status'] == 'paid' &&
                     bookingDate.month == currentMonth &&
                     bookingDate.year == currentYear;
            })
            .fold<double>(0.0, (sum, b) => sum + (b['total_price'] as num));

        return {
          'total': totalBookings,
          'pending': pendingBookings,
          'confirmed': confirmedBookings,
          'completed': completedBookings,
          'cancelled': cancelledBookings,
          'totalRevenue': totalRevenue,
          'monthlyRevenue': monthlyRevenue,
        };
      }
      
      return {
        'total': 0,
        'pending': 0,
        'confirmed': 0,
        'completed': 0,
        'cancelled': 0,
        'totalRevenue': 0.0,
        'monthlyRevenue': 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get booking stats: $e');
    }
  }

  // Check property availability for dates
  Future<bool> checkPropertyAvailability({
    required String propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('check_in, check_out, status')
          .eq('property_id', propertyId)
          .neq('status', 'cancelled');

      if (response != null) {
        final bookings = response as List;
        
        for (final booking in bookings) {
          final existingCheckIn = DateTime.parse(booking['check_in']);
          final existingCheckOut = DateTime.parse(booking['check_in']);
          
          // Check for date overlap
          if ((checkIn.isBefore(existingCheckOut) && checkOut.isAfter(existingCheckIn))) {
            return false; // Property is not available for these dates
          }
        }
      }
      
      return true; // Property is available
    } catch (e) {
      throw Exception('Failed to check property availability: $e');
    }
  }

  // Get upcoming bookings
  Future<List<BookingModel>> getUpcomingBookings(String userId, {bool isHost = false}) async {
    try {
      final now = DateTime.now();
      final userIdField = isHost ? 'host_id' : 'tenant_id';
      
      final response = await _supabase
          .from('bookings')
          .select()
          .eq(userIdField, userId)
          .gte('check_in', now.toIso8601String())
          .in_('status', ['pending', 'confirmed'])
          .order('check_in', ascending: true);

      if (response != null) {
        return (response as List)
            .map((json) => BookingModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get upcoming bookings: $e');
    }
  }

  // Get past bookings
  Future<List<BookingModel>> getPastBookings(String userId, {bool isHost = false}) async {
    try {
      final now = DateTime.now();
      final userIdField = isHost ? 'host_id' : 'tenant_id';
      
      final response = await _supabase
          .from('bookings')
          .select()
          .eq(userIdField, userId)
          .lt('check_out', now.toIso8601String())
          .order('check_out', ascending: false);

      if (response != null) {
        return (response as List)
            .map((json) => BookingModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get past bookings: $e');
    }
  }
}