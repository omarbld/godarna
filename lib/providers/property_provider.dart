import 'package:flutter/material.dart';
import 'package:godarna/models/property_model.dart';
import 'package:godarna/services/property_service.dart';

class PropertyProvider extends ChangeNotifier {
  final PropertyService _propertyService = PropertyService();
  
  List<PropertyModel> _properties = [];
  List<PropertyModel> _filteredProperties = [];
  PropertyModel? _selectedProperty;
  bool _isLoading = false;
  String? _error;
  
  // Search and filter state
  String _searchQuery = '';
  String _selectedCity = '';
  String _selectedPropertyType = '';
  double _minPrice = 0;
  double _maxPrice = 10000;
  int _selectedGuests = 1;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  // Getters
  List<PropertyModel> get properties => _properties;
  List<PropertyModel> get filteredProperties => _filteredProperties;
  PropertyModel? get selectedProperty => _selectedProperty;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Search and filter getters
  String get searchQuery => _searchQuery;
  String get selectedCity => _selectedCity;
  String get selectedPropertyType => _selectedPropertyType;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  int get selectedGuests => _selectedGuests;
  DateTime? get checkInDate => _checkInDate;
  DateTime? get checkOutDate => _checkOutDate;

  // Initialize properties
  Future<void> initialize() async {
    try {
      _setLoading(true);
      await fetchProperties();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch all properties
  Future<void> fetchProperties() async {
    try {
      _setLoading(true);
      _clearError();
      
      final properties = await _propertyService.getProperties();
      _properties = properties;
      _applyFilters();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch properties by host
  Future<void> fetchPropertiesByHost(String hostId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final properties = await _propertyService.getPropertiesByHost(hostId);
      _properties = properties;
      _applyFilters();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get property by ID
  Future<PropertyModel?> getPropertyById(String propertyId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final property = await _propertyService.getPropertyById(propertyId);
      _selectedProperty = property;
      return property;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Add new property
  Future<bool> addProperty(PropertyModel property) async {
    try {
      _setLoading(true);
      _clearError();
      
      final newProperty = await _propertyService.addProperty(property);
      if (newProperty != null) {
        _properties.add(newProperty);
        _applyFilters();
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

  // Update property
  Future<bool> updateProperty(PropertyModel property) async {
    try {
      _setLoading(true);
      _clearError();
      
      final updatedProperty = await _propertyService.updateProperty(property);
      if (updatedProperty != null) {
        final index = _properties.indexWhere((p) => p.id == property.id);
        if (index != -1) {
          _properties[index] = updatedProperty;
          _applyFilters();
          notifyListeners();
        }
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

  // Delete property
  Future<bool> deleteProperty(String propertyId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _propertyService.deleteProperty(propertyId);
      if (success) {
        _properties.removeWhere((p) => p.id == propertyId);
        _applyFilters();
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

  // Search and filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setSelectedCity(String city) {
    _selectedCity = city;
    _applyFilters();
  }

  void setSelectedPropertyType(String propertyType) {
    _selectedPropertyType = propertyType;
    _applyFilters();
  }

  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilters();
  }

  void setSelectedGuests(int guests) {
    _selectedGuests = guests;
    _applyFilters();
  }

  void setDateRange(DateTime? checkIn, DateTime? checkOut) {
    _checkInDate = checkIn;
    _checkOutDate = checkOut;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCity = '';
    _selectedPropertyType = '';
    _minPrice = 0;
    _maxPrice = 10000;
    _selectedGuests = 1;
    _checkInDate = null;
    _checkOutDate = null;
    _applyFilters();
  }

  // Apply filters to properties
  void _applyFilters() {
    _filteredProperties = _properties.where((property) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!property.title.toLowerCase().contains(query) &&
            !property.description.toLowerCase().contains(query) &&
            !property.city.toLowerCase().contains(query) &&
            !property.area.toLowerCase().contains(query)) {
          return false;
        }
      }

      // City filter
      if (_selectedCity.isNotEmpty && property.city != _selectedCity) {
        return false;
      }

      // Property type filter
      if (_selectedPropertyType.isNotEmpty && property.propertyType != _selectedPropertyType) {
        return false;
      }

      // Price filter
      if (property.pricePerNight < _minPrice || property.pricePerNight > _maxPrice) {
        return false;
      }

      // Guests filter
      if (property.maxGuests < _selectedGuests) {
        return false;
      }

      // Availability filter
      if (!property.isAvailable) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // Get available cities
  List<String> get availableCities {
    final cities = _properties.map((p) => p.city).toSet().toList();
    cities.sort();
    return cities;
  }

  // Get available property types
  List<String> get availablePropertyTypes {
    return ['apartment', 'villa', 'riad', 'studio'];
  }

  // Get price range
  Map<String, double> get priceRange {
    if (_properties.isEmpty) {
      return {'min': 0, 'max': 10000};
    }
    
    final prices = _properties.map((p) => p.pricePerNight).toList();
    return {
      'min': prices.reduce((a, b) => a < b ? a : b),
      'max': prices.reduce((a, b) => a > b ? a : b),
    };
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