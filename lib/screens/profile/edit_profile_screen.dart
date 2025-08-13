import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godarna/providers/auth_provider.dart';
import 'package:godarna/constants/app_colors.dart';
import 'package:godarna/constants/app_strings.dart';
import 'package:godarna/widgets/custom_button.dart';
import 'package:godarna/widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser!;
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _phoneController.text = user.phone ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الملف الشخصي بنجاح'),
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
        title: Text(AppStrings.getString('editProfile', context)),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
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
                  children: [
                    CustomTextField(
                      controller: _firstNameController,
                      labelText: AppStrings.getString('firstName', context),
                      hintText: AppStrings.getString('firstNameHint', context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'مطلوب';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      controller: _lastNameController,
                      labelText: AppStrings.getString('lastName', context),
                      hintText: AppStrings.getString('lastNameHint', context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'مطلوب';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      controller: _phoneController,
                      labelText: AppStrings.getString('phone', context),
                      hintText: AppStrings.getString('phoneHint', context),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: AppStrings.getString('saveChanges', context),
                  onPressed: _isLoading ? null : _updateProfile,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}