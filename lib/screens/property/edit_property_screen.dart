import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godarna/providers/property_provider.dart';
import 'package:godarna/constants/app_colors.dart';
import 'package:godarna/constants/app_strings.dart';
import 'package:godarna/widgets/custom_button.dart';
import 'package:godarna/widgets/custom_text_field.dart';
import 'package:godarna/models/property_model.dart';

class EditPropertyScreen extends StatefulWidget {
  final PropertyModel property;

  const EditPropertyScreen({
    super.key,
    required this.property,
  });

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _pricePerNightController = TextEditingController();
  final _pricePerMonthController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _maxGuestsController = TextEditingController();
  
  String _selectedPropertyType = 'apartment';
  List<String> _selectedAmenities = [];
  bool _isLoading = false;

  final List<String> _availableAmenities = [
    'مكيف هواء',
    'تدفئة',
    'مطبخ',
    'غسالة',
    'واي فاي',
    'تلفاز',
    'موقف سيارات',
    'حديقة',
    'بركة سباحة',
    'مصعد',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController.text = widget.property.title;
    _descriptionController.text = widget.property.description;
    _addressController.text = widget.property.address;
    _cityController.text = widget.property.city;
    _areaController.text = widget.property.area;
    _pricePerNightController.text = widget.property.pricePerNight.toString();
    _pricePerMonthController.text = widget.property.pricePerMonth.toString();
    _bedroomsController.text = widget.property.bedrooms.toString();
    _bathroomsController.text = widget.property.bathrooms.toString();
    _maxGuestsController.text = widget.property.maxGuests.toString();
    _selectedPropertyType = widget.property.propertyType;
    _selectedAmenities = List.from(widget.property.amenities);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _pricePerNightController.dispose();
    _pricePerMonthController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _maxGuestsController.dispose();
    super.dispose();
  }

  void _toggleAmenity(String amenity) {
    setState(() {
      if (_selectedAmenities.contains(amenity)) {
        _selectedAmenities.remove(amenity);
      } else {
        _selectedAmenities.add(amenity);
      }
    });
  }

  Future<void> _updateProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);

      // Create updated property model
      final updatedProperty = widget.property.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        propertyType: _selectedPropertyType,
        pricePerNight: double.parse(_pricePerNightController.text),
        pricePerMonth: double.parse(_pricePerMonthController.text),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        area: _areaController.text.trim(),
        bedrooms: int.parse(_bedroomsController.text),
        bathrooms: int.parse(_bathroomsController.text),
        maxGuests: int.parse(_maxGuestsController.text),
        amenities: _selectedAmenities,
        updatedAt: DateTime.now(),
      );

      final success = await propertyProvider.updateProperty(updatedProperty);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث العقار بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(AppStrings.getString('editProperty', context)),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Basic Information
              _buildSection(
                title: 'المعلومات الأساسية',
                children: [
                  CustomTextField(
                    controller: _titleController,
                    labelText: 'عنوان العقار',
                    hintText: 'أدخل عنوان العقار',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'مطلوب';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descriptionController,
                    labelText: 'وصف العقار',
                    hintText: 'أدخل وصفاً مفصلاً للعقار',
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'مطلوب';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedPropertyType,
                    decoration: const InputDecoration(
                      labelText: 'نوع العقار',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'apartment', child: Text('شقة')),
                      DropdownMenuItem(value: 'villa', child: Text('فيلا')),
                      DropdownMenuItem(value: 'riad', child: Text('رياض')),
                      DropdownMenuItem(value: 'studio', child: Text('استوديو')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPropertyType = value!;
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Location Information
              _buildSection(
                title: 'معلومات الموقع',
                children: [
                  CustomTextField(
                    controller: _addressController,
                    labelText: 'العنوان التفصيلي',
                    hintText: 'أدخل العنوان الكامل',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'مطلوب';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _cityController,
                          labelText: 'المدينة',
                          hintText: 'أدخل اسم المدينة',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'مطلوب';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _areaController,
                          labelText: 'المنطقة',
                          hintText: 'أدخل اسم المنطقة',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'مطلوب';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Property Details
              _buildSection(
                title: 'تفاصيل العقار',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _bedroomsController,
                          labelText: 'عدد غرف النوم',
                          hintText: '0',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'مطلوب';
                            }
                            if (int.tryParse(value) == null) {
                              return 'يجب أن يكون رقماً';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _bathroomsController,
                          labelText: 'عدد الحمامات',
                          hintText: '0',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'مطلوب';
                            }
                            if (int.tryParse(value) == null) {
                              return 'يجب أن يكون رقماً';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _maxGuestsController,
                    labelText: 'الحد الأقصى للضيوف',
                    hintText: '1',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'مطلوب';
                      }
                      if (int.tryParse(value) == null) {
                        return 'يجب أن يكون رقماً';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Pricing
              _buildSection(
                title: 'الأسعار',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _pricePerNightController,
                          labelText: 'السعر لليلة الواحدة (درهم)',
                          hintText: '0',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'مطلوب';
                            }
                            if (double.tryParse(value) == null) {
                              return 'يجب أن يكون رقماً';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _pricePerMonthController,
                          labelText: 'السعر للشهر (درهم)',
                          hintText: '0',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'مطلوب';
                            }
                            if (double.tryParse(value) == null) {
                              return 'يجب أن يكون رقماً';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Amenities
              _buildSection(
                title: 'المرافق',
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _availableAmenities.map((amenity) {
                      final isSelected = _selectedAmenities.contains(amenity);
                      return GestureDetector(
                        onTap: () => _toggleAmenity(amenity),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryRed : AppColors.backgroundGrey,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryRed : AppColors.borderGrey,
                            ),
                          ),
                          child: Text(
                            amenity,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Update Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: AppStrings.getString('updateProperty', context),
                  onPressed: _isLoading ? null : _updateProperty,
                  isLoading: _isLoading,
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}