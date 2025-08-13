import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:godarna/models/property_model.dart';
import 'package:godarna/models/booking_model.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Get user properties count
      final propertiesResponse = await _supabase
          .from('properties')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('host_id', userId);

      // Get user bookings count
      final bookingsResponse = await _supabase
          .from('bookings')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('tenant_id', userId);

      // Get total earnings (for hosts)
      final earningsResponse = await _supabase
          .from('bookings')
          .select('total_price')
          .eq('host_id', userId)
          .eq('status', 'completed');

      double totalEarnings = 0;
      if (earningsResponse != null) {
        for (final booking in earningsResponse) {
          totalEarnings += (booking['total_price'] ?? 0).toDouble();
        }
      }

      return {
        'propertiesCount': propertiesResponse.count ?? 0,
        'bookingsCount': bookingsResponse.count ?? 0,
        'totalEarnings': totalEarnings,
        'averageRating': await _getUserAverageRating(userId),
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {
        'propertiesCount': 0,
        'bookingsCount': 0,
        'totalEarnings': 0.0,
        'averageRating': 0.0,
      };
    }
  }

  // Get property statistics
  Future<Map<String, dynamic>> getPropertyStats(String propertyId) async {
    try {
      // Get bookings count
      final bookingsResponse = await _supabase
          .from('bookings')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('property_id', propertyId);

      // Get total revenue
      final revenueResponse = await _supabase
          .from('bookings')
          .select('total_price')
          .eq('property_id', propertyId)
          .eq('status', 'completed');

      double totalRevenue = 0;
      if (revenueResponse != null) {
        for (final booking in revenueResponse) {
          totalRevenue += (booking['total_price'] ?? 0).toDouble();
        }
      }

      // Get occupancy rate
      final occupancyRate = await _calculateOccupancyRate(propertyId);

      return {
        'bookingsCount': bookingsResponse.count ?? 0,
        'totalRevenue': totalRevenue,
        'occupancyRate': occupancyRate,
        'averageRating': await _getPropertyAverageRating(propertyId),
      };
    } catch (e) {
      print('Error getting property stats: $e');
      return {
        'bookingsCount': 0,
        'totalRevenue': 0.0,
        'occupancyRate': 0.0,
        'averageRating': 0.0,
      };
    }
  }

  // Get platform statistics (for admins)
  Future<Map<String, dynamic>> getPlatformStats() async {
    try {
      // Get total users
      final usersResponse = await _supabase
          .from('users')
          .select('id', const FetchOptions(count: CountOption.exact));

      // Get total properties
      final propertiesResponse = await _supabase
          .from('properties')
          .select('id', const FetchOptions(count: CountOption.exact));

      // Get total bookings
      final bookingsResponse = await _supabase
          .from('bookings')
          .select('id', const FetchOptions(count: CountOption.exact));

      // Get total revenue
      final revenueResponse = await _supabase
          .from('bookings')
          .select('total_price')
          .eq('status', 'completed');

      double totalRevenue = 0;
      if (revenueResponse != null) {
        for (final booking in revenueResponse) {
          totalRevenue += (booking['total_price'] ?? 0).toDouble();
        }
      }

      // Get popular cities
      final popularCities = await _getPopularCities();

      return {
        'totalUsers': usersResponse.count ?? 0,
        'totalProperties': propertiesResponse.count ?? 0,
        'totalBookings': bookingsResponse.count ?? 0,
        'totalRevenue': totalRevenue,
        'popularCities': popularCities,
        'averageRating': await _getPlatformAverageRating(),
      };
    } catch (e) {
      print('Error getting platform stats: $e');
      return {
        'totalUsers': 0,
        'totalProperties': 0,
        'totalBookings': 0,
        'totalRevenue': 0.0,
        'popularCities': [],
        'averageRating': 0.0,
      };
    }
  }

  // Get monthly revenue for a property
  Future<List<Map<String, dynamic>>> getMonthlyRevenue(String propertyId, int months) async {
    try {
      final List<Map<String, dynamic>> monthlyData = [];
      final now = DateTime.now();

      for (int i = 0; i < months; i++) {
        final month = DateTime(now.year, now.month - i, 1);
        final nextMonth = DateTime(now.year, now.month - i + 1, 1);

        final response = await _supabase
            .from('bookings')
            .select('total_price')
            .eq('property_id', propertyId)
            .eq('status', 'completed')
            .gte('check_in', month.toIso8601String())
            .lt('check_in', nextMonth.toIso8601String());

        double monthlyRevenue = 0;
        if (response != null) {
          for (final booking in response) {
            monthlyRevenue += (booking['total_price'] ?? 0).toDouble();
          }
        }

        monthlyData.add({
          'month': month.month,
          'year': month.year,
          'revenue': monthlyRevenue,
        });
      }

      return monthlyData.reversed.toList();
    } catch (e) {
      print('Error getting monthly revenue: $e');
      return [];
    }
  }

  // Get popular property types
  Future<List<Map<String, dynamic>>> getPopularPropertyTypes() async {
    try {
      final response = await _supabase
          .from('properties')
          .select('property_type')
          .eq('is_active', true);

      final Map<String, int> typeCounts = {};
      
      if (response != null) {
        for (final property in response) {
          final type = property['property_type'] ?? 'unknown';
          typeCounts[type] = (typeCounts[type] ?? 0) + 1;
        }
      }

      final List<Map<String, dynamic>> popularTypes = [];
      typeCounts.forEach((type, count) {
        popularTypes.add({
          'type': type,
          'count': count,
          'percentage': (count / (response?.length ?? 1)) * 100,
        });
      });

      popularTypes.sort((a, b) => b['count'].compareTo(a['count']));
      return popularTypes;
    } catch (e) {
      print('Error getting popular property types: $e');
      return [];
    }
  }

  // Get booking trends
  Future<List<Map<String, dynamic>>> getBookingTrends(int days) async {
    try {
      final List<Map<String, dynamic>> trends = [];
      final now = DateTime.now();

      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final nextDate = date.add(const Duration(days: 1));

        final response = await _supabase
            .from('bookings')
            .select('id', const FetchOptions(count: CountOption.exact))
            .gte('created_at', date.toIso8601String())
            .lt('created_at', nextDate.toIso8601String());

        trends.add({
          'date': date.toIso8601String().split('T')[0],
          'bookings': response.count ?? 0,
        });
      }

      return trends.reversed.toList();
    } catch (e) {
      print('Error getting booking trends: $e');
      return [];
    }
  }

  // Helper methods
  Future<double> _getUserAverageRating(String userId) async {
    try {
      final response = await _supabase
          .from('properties')
          .select('rating')
          .eq('host_id', userId)
          .not('rating', 'eq', 0);

      if (response == null || response.isEmpty) return 0.0;

      double totalRating = 0;
      for (final property in response) {
        totalRating += (property['rating'] ?? 0).toDouble();
      }

      return totalRating / response.length;
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> _getPropertyAverageRating(String propertyId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('rating')
          .eq('property_id', propertyId)
          .not('rating', 'is', null);

      if (response == null || response.isEmpty) return 0.0;

      double totalRating = 0;
      for (final booking in response) {
        totalRating += (booking['rating'] ?? 0).toDouble();
      }

      return totalRating / response.length;
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> _getPlatformAverageRating() async {
    try {
      final response = await _supabase
          .from('properties')
          .select('rating')
          .not('rating', 'eq', 0);

      if (response == null || response.isEmpty) return 0.0;

      double totalRating = 0;
      for (final property in response) {
        totalRating += (property['rating'] ?? 0).toDouble();
      }

      return totalRating / response.length;
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> _calculateOccupancyRate(String propertyId) async {
    try {
      // This is a simplified calculation
      // In a real app, you'd need to consider property availability dates
      final response = await _supabase
          .from('bookings')
          .select('check_in, check_out')
          .eq('property_id', propertyId)
          .eq('status', 'completed');

      if (response == null || response.isEmpty) return 0.0;

      // TODO: Implement proper occupancy rate calculation
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> _getPopularCities() async {
    try {
      final response = await _supabase
          .from('properties')
          .select('city')
          .eq('is_active', true);

      final Map<String, int> cityCounts = {};
      
      if (response != null) {
        for (final property in response) {
          final city = property['city'] ?? 'unknown';
          cityCounts[city] = (cityCounts[city] ?? 0) + 1;
        }
      }

      final List<Map<String, dynamic>> popularCities = [];
      cityCounts.forEach((city, count) {
        popularCities.add({
          'city': city,
          'count': count,
        });
      });

      popularCities.sort((a, b) => b['count'].compareTo(a['count']));
      return popularCities.take(10).toList();
    } catch (e) {
      return [];
    }
  }

  // Track user action
  Future<void> trackUserAction(String userId, String action, Map<String, dynamic>? data) async {
    try {
      await _supabase.from('user_actions').insert({
        'user_id': userId,
        'action': action,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking user action: $e');
    }
  }

  // Track property view
  Future<void> trackPropertyView(String propertyId, String? userId) async {
    try {
      await _supabase.from('property_views').insert({
        'property_id': propertyId,
        'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking property view: $e');
    }
  }
}