import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:godarna/models/property_model.dart';

class PropertyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all properties
  Future<List<PropertyModel>> getProperties() async {
    try {
      final response = await _supabase
          .from('properties')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (response != null) {
        return (response as List)
            .map((json) => PropertyModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get properties: $e');
    }
  }

  // Get property by ID
  Future<PropertyModel?> getPropertyById(String propertyId) async {
    try {
      final response = await _supabase
          .from('properties')
          .select()
          .eq('id', propertyId)
          .single();

      if (response != null) {
        return PropertyModel.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get property: $e');
    }
  }

  // Get properties by host
  Future<List<PropertyModel>> getPropertiesByHost(String hostId) async {
    try {
      final response = await _supabase
          .from('properties')
          .select()
          .eq('host_id', hostId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (response != null) {
        return (response as List)
            .map((json) => PropertyModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get host properties: $e');
    }
  }

  // Add new property
  Future<PropertyModel?> addProperty(PropertyModel property) async {
    try {
      final propertyData = {
        'host_id': property.hostId,
        'title': property.title,
        'description': property.description,
        'property_type': property.propertyType,
        'price_per_night': property.pricePerNight,
        'price_per_month': property.pricePerMonth,
        'address': property.address,
        'city': property.city,
        'area': property.area,
        'latitude': property.latitude,
        'longitude': property.longitude,
        'bedrooms': property.bedrooms,
        'bathrooms': property.bathrooms,
        'max_guests': property.maxGuests,
        'amenities': property.amenities,
        'photos': property.photos,
        'is_available': property.isAvailable,
        'is_verified': property.isVerified,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('properties')
          .insert(propertyData)
          .select()
          .single();

      if (response != null) {
        return PropertyModel.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to add property: $e');
    }
  }

  // Update property
  Future<PropertyModel?> updateProperty(PropertyModel property) async {
    try {
      final updateData = {
        'title': property.title,
        'description': property.description,
        'property_type': property.propertyType,
        'price_per_night': property.pricePerNight,
        'price_per_month': property.pricePerMonth,
        'address': property.address,
        'city': property.city,
        'area': property.area,
        'latitude': property.latitude,
        'longitude': property.longitude,
        'bedrooms': property.bedrooms,
        'bathrooms': property.bathrooms,
        'max_guests': property.maxGuests,
        'amenities': property.amenities,
        'photos': property.photos,
        'is_available': property.isAvailable,
        'is_verified': property.isVerified,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('properties')
          .update(updateData)
          .eq('id', property.id)
          .select()
          .single();

      if (response != null) {
        return PropertyModel.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update property: $e');
    }
  }

  // Delete property
  Future<bool> deleteProperty(String propertyId) async {
    try {
      await _supabase
          .from('properties')
          .update({'is_active': false})
          .eq('id', propertyId);
      
      return true;
    } catch (e) {
      throw Exception('Failed to delete property: $e');
    }
  }

  // Search properties
  Future<List<PropertyModel>> searchProperties({
    String? query,
    String? city,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    int? maxGuests,
    DateTime? checkIn,
    DateTime? checkOut,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('properties')
          .select()
          .eq('is_active', true)
          .eq('is_available', true);

      if (city != null && city.isNotEmpty) {
        queryBuilder = queryBuilder.eq('city', city);
      }

      if (propertyType != null && propertyType.isNotEmpty) {
        queryBuilder = queryBuilder.eq('property_type', propertyType);
      }

      if (minPrice != null) {
        queryBuilder = queryBuilder.gte('price_per_night', minPrice);
      }

      if (maxPrice != null) {
        queryBuilder = queryBuilder.lte('price_per_night', maxPrice);
      }

      if (maxGuests != null) {
        queryBuilder = queryBuilder.gte('max_guests', maxGuests);
      }

      final response = await queryBuilder.order('created_at', ascending: false);

      if (response != null) {
        var properties = (response as List)
            .map((json) => PropertyModel.fromJson(json))
            .toList();

        // Apply text search filter if query is provided
        if (query != null && query.isNotEmpty) {
          final lowerQuery = query.toLowerCase();
          properties = properties.where((property) {
            return property.title.toLowerCase().contains(lowerQuery) ||
                   property.description.toLowerCase().contains(lowerQuery) ||
                   property.city.toLowerCase().contains(lowerQuery) ||
                   property.area.toLowerCase().contains(lowerQuery);
          }).toList();
        }

        return properties;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search properties: $e');
    }
  }

  // Get properties by location (nearby)
  Future<List<PropertyModel>> getPropertiesByLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      // Simple distance calculation (in production, use PostGIS or similar)
      final response = await _supabase
          .from('properties')
          .select()
          .eq('is_active', true)
          .eq('is_available', true);

      if (response != null) {
        final properties = (response as List)
            .map((json) => PropertyModel.fromJson(json))
            .toList();

        // Filter by distance
        return properties.where((property) {
          final distance = _calculateDistance(
            latitude,
            longitude,
            property.latitude,
            property.longitude,
          );
          return distance <= radiusKm;
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get properties by location: $e');
    }
  }

  // Update property availability
  Future<bool> updatePropertyAvailability(String propertyId, bool isAvailable) async {
    try {
      await _supabase
          .from('properties')
          .update({
            'is_available': isAvailable,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', propertyId);
      
      return true;
    } catch (e) {
      throw Exception('Failed to update property availability: $e');
    }
  }

  // Update property photos
  Future<bool> updatePropertyPhotos(String propertyId, List<String> photos) async {
    try {
      await _supabase
          .from('properties')
          .update({
            'photos': photos,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', propertyId);
      
      return true;
    } catch (e) {
      throw Exception('Failed to update property photos: $e');
    }
  }

  // Get property statistics
  Future<Map<String, dynamic>> getPropertyStats() async {
    try {
      final response = await _supabase
          .from('properties')
          .select('property_type, city, price_per_night, rating');

      if (response != null) {
        final properties = response as List;
        
        final totalProperties = properties.length;
        final totalRevenue = properties.fold<double>(
          0.0,
          (sum, p) => sum + (p['price_per_night'] as num),
        );
        
        final propertyTypes = <String, int>{};
        final cities = <String, int>{};
        
        for (final property in properties) {
          final type = property['property_type'] as String;
          propertyTypes[type] = (propertyTypes[type] ?? 0) + 1;
          
          final city = property['city'] as String;
          cities[city] = (cities[city] ?? 0) + 1;
        }

        return {
          'total': totalProperties,
          'revenue': totalRevenue,
          'propertyTypes': propertyTypes,
          'cities': cities,
        };
      }
      
      return {
        'total': 0,
        'revenue': 0.0,
        'propertyTypes': {},
        'cities': {},
      };
    } catch (e) {
      throw Exception('Failed to get property stats: $e');
    }
  }

  // Private helper method to calculate distance between two points
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = (dLat / 2).sin() * (dLat / 2).sin() +
               (lat1.sin() * lat2.sin() * (dLon / 2).sin() * (dLon / 2).sin());
    final c = 2 * (a.sqrt() / (1 - a).sqrt()).atan();
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}