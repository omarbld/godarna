import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godarna/providers/property_provider.dart';
import 'package:godarna/providers/language_provider.dart';
import 'package:godarna/constants/app_colors.dart';
import 'package:godarna/constants/app_strings.dart';
import 'package:godarna/widgets/custom_button.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedCity;
  String? _selectedPropertyType;
  RangeValues _priceRange = const RangeValues(0, 10000);
  int _selectedGuests = 1;

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final propertyProvider = Provider.of<PropertyProvider>(context);
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  AppStrings.getString('filters', context),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    propertyProvider.clearFilters();
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppStrings.getString('clearFilters', context),
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Filters Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // City Filter
                _buildFilterSection(
                  title: AppStrings.getString('city', context),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('جميع المدن'),
                      ),
                      ...propertyProvider.availableCities.map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Property Type Filter
                _buildFilterSection(
                  title: AppStrings.getString('propertyTypeFilter', context),
                  child: DropdownButtonFormField<String>(
                    value: _selectedPropertyType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('جميع الأنواع'),
                      ),
                      ...propertyProvider.availablePropertyTypes.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type == 'apartment' ? 'شقة' : 
                                   type == 'villa' ? 'فيلا' : 
                                   type == 'riad' ? 'رياض' : 'استوديو'),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPropertyType = value;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Price Range Filter
                _buildFilterSection(
                  title: AppStrings.getString('priceRange', context),
                  child: Column(
                    children: [
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 10000,
                        divisions: 100,
                        labels: RangeLabels(
                          '${_priceRange.start.round()} درهم',
                          '${_priceRange.end.round()} درهم',
                        ),
                        onChanged: (values) {
                          setState(() {
                            _priceRange = values;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${_priceRange.start.round()} درهم'),
                          Text('${_priceRange.end.round()} درهم'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Guests Filter
                _buildFilterSection(
                  title: AppStrings.getString('guestsFilter', context),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _selectedGuests > 1
                            ? () => setState(() => _selectedGuests--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$_selectedGuests',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _selectedGuests++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: AppStrings.getString('applyFilters', context),
                    onPressed: () {
                      propertyProvider.setSelectedCity(_selectedCity ?? '');
                      propertyProvider.setSelectedPropertyType(_selectedPropertyType ?? '');
                      propertyProvider.setPriceRange(_priceRange.start, _priceRange.end);
                      propertyProvider.setSelectedGuests(_selectedGuests);
                      Navigator.pop(context);
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}