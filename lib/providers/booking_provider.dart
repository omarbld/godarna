import 'package:flutter/material.dart';
import 'package:godarna/models/booking_model.dart';
import 'package:godarna/services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  
  List<BookingModel> _bookings = [];
  List<BookingModel> _userBookings = [];
  List<BookingModel> _hostBookings = [];
  BookingModel? _selectedBooking;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BookingModel> get bookings => _bookings;
  List<BookingModel> get userBookings => _userBookings;
  List<BookingModel> get hostBookings => _hostBookings;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize bookings
  Future<void> initialize() async {
    try {
      _setLoading(true);
      await fetchBookings();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch all bookings (for admin)
  Future<void> fetchBookings() async {
    try {
      _setLoading(true);
      _clearError();
      
      final bookings = await _bookingService.getBookings();
      _bookings = bookings;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch user bookings (as tenant)
  Future<void> fetchUserBookings(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final bookings = await _bookingService.getBookingsByTenant(userId);
      _userBookings = bookings;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch host bookings
  Future<void> fetchHostBookings(String hostId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final bookings = await _bookingService.getBookingsByHost(hostId);
      _hostBookings = bookings;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final booking = await _bookingService.getBookingById(bookingId);
      _selectedBooking = booking;
      return booking;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Create new booking
  Future<bool> createBooking({
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
      _setLoading(true);
      _clearError();
      
      final booking = await _bookingService.createBooking(
        propertyId: propertyId,
        tenantId: tenantId,
        hostId: hostId,
        checkIn: checkIn,
        checkOut: checkOut,
        nights: nights,
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      
      if (booking != null) {
        _userBookings.add(booking);
        _bookings.add(booking);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _bookingService.updateBookingStatus(bookingId, status);
      if (success) {
        // Update local booking
        _updateLocalBookingStatus(bookingId, status);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Confirm booking (host action)
  Future<bool> confirmBooking(String bookingId) async {
    return await updateBookingStatus(bookingId, 'confirmed');
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    return await updateBookingStatus(bookingId, 'cancelled');
  }

  // Complete booking
  Future<bool> completeBooking(String bookingId) async {
    return await updateBookingStatus(bookingId, 'completed');
  }

  // Update payment status
  Future<bool> updatePaymentStatus(String bookingId, String paymentStatus) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _bookingService.updatePaymentStatus(bookingId, paymentStatus);
      if (success) {
        // Update local booking
        _updateLocalPaymentStatus(bookingId, paymentStatus);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add review and rating
  Future<bool> addReview({
    required String bookingId,
    required double rating,
    required String review,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _bookingService.addReview(
        bookingId: bookingId,
        rating: rating,
        review: review,
      );
      
      if (success) {
        // Update local booking
        _updateLocalReview(bookingId, rating, review);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get booking statistics
  Map<String, dynamic> getBookingStats() {
    final totalBookings = _bookings.length;
    final pendingBookings = _bookings.where((b) => b.isPending).length;
    final confirmedBookings = _bookings.where((b) => b.isConfirmed).length;
    final completedBookings = _bookings.where((b) => b.isCompleted).length;
    final cancelledBookings = _bookings.where((b) => b.isCancelled).length;
    
    final totalRevenue = _bookings
        .where((b) => b.isPaid)
        .fold(0.0, (sum, b) => sum + b.totalPrice);
    
    return {
      'total': totalBookings,
      'pending': pendingBookings,
      'confirmed': confirmedBookings,
      'completed': completedBookings,
      'cancelled': cancelledBookings,
      'revenue': totalRevenue,
    };
  }

  // Get user booking statistics
  Map<String, dynamic> getUserBookingStats(String userId) {
    final userBookings = _bookings.where((b) => b.tenantId == userId).toList();
    final totalBookings = userBookings.length;
    final activeBookings = userBookings.where((b) => b.isConfirmed || b.isPending).length;
    final completedBookings = userBookings.where((b) => b.isCompleted).length;
    
    return {
      'total': totalBookings,
      'active': activeBookings,
      'completed': completedBookings,
    };
  }

  // Get host booking statistics
  Map<String, dynamic> getHostBookingStats(String hostId) {
    final hostBookings = _bookings.where((b) => b.hostId == hostId).toList();
    final totalBookings = hostBookings.length;
    final pendingBookings = hostBookings.where((b) => b.isPending).length;
    final confirmedBookings = hostBookings.where((b) => b.isConfirmed).length;
    final completedBookings = hostBookings.where((b) => b.isCompleted).length;
    
    final totalRevenue = hostBookings
        .where((b) => b.isPaid)
        .fold(0.0, (sum, b) => sum + b.totalPrice);
    
    return {
      'total': totalBookings,
      'pending': pendingBookings,
      'confirmed': confirmedBookings,
      'completed': completedBookings,
      'revenue': totalRevenue,
    };
  }

  // Private methods for updating local state
  void _updateLocalBookingStatus(String bookingId, String status) {
    final allBookings = [..._bookings, ..._userBookings, ..._hostBookings];
    for (final booking in allBookings) {
      if (booking.id == bookingId) {
        final updatedBooking = booking.copyWith(status: status);
        _updateBookingInLists(updatedBooking);
        break;
      }
    }
  }

  void _updateLocalPaymentStatus(String bookingId, String paymentStatus) {
    final allBookings = [..._bookings, ..._userBookings, ..._hostBookings];
    for (final booking in allBookings) {
      if (booking.id == bookingId) {
        final updatedBooking = booking.copyWith(paymentStatus: paymentStatus);
        _updateBookingInLists(updatedBooking);
        break;
      }
    }
  }

  void _updateLocalReview(String bookingId, double rating, String review) {
    final allBookings = [..._bookings, ..._userBookings, ..._hostBookings];
    for (final booking in allBookings) {
      if (booking.id == bookingId) {
        final updatedBooking = booking.copyWith(
          rating: rating,
          review: review,
          reviewDate: DateTime.now(),
        );
        _updateBookingInLists(updatedBooking);
        break;
      }
    }
  }

  void _updateBookingInLists(BookingModel updatedBooking) {
    // Update in main bookings list
    final mainIndex = _bookings.indexWhere((b) => b.id == updatedBooking.id);
    if (mainIndex != -1) {
      _bookings[mainIndex] = updatedBooking;
    }
    
    // Update in user bookings list
    final userIndex = _userBookings.indexWhere((b) => b.id == updatedBooking.id);
    if (userIndex != -1) {
      _userBookings[userIndex] = updatedBooking;
    }
    
    // Update in host bookings list
    final hostIndex = _hostBookings.indexWhere((b) => b.id == updatedBooking.id);
    if (hostIndex != -1) {
      _hostBookings[hostIndex] = updatedBooking;
    }
    
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }
}