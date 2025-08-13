import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godarna/providers/auth_provider.dart';
import 'package:godarna/providers/language_provider.dart';
import 'package:godarna/constants/app_colors.dart';
import 'package:godarna/constants/app_strings.dart';
import 'package:godarna/screens/main/home_screen.dart';
import 'package:godarna/widgets/custom_button.dart';
import 'package:godarna/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isOtpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.sendOtp(_emailController.text.trim());
      
      if (success && mounted) {
        setState(() => _isOtpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getString('otpSent', context)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.verifyOtp(
        _emailController.text.trim(),
        _otpController.text.trim(),
      );
      
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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

  void _resetForm() {
    setState(() {
      _isOtpSent = false;
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: languageProvider.isArabic 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Title
                      Text(
                        AppStrings.getString('login', context),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Subtitle
                      Text(
                        AppStrings.getString('appSlogan', context),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  labelText: AppStrings.getString('email', context),
                  hintText: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isOtpSent,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.getString('required', context);
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return AppStrings.getString('invalidEmail', context);
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // OTP Field (shown after OTP is sent)
                if (_isOtpSent) ...[
                  CustomTextField(
                    controller: _otpController,
                    labelText: AppStrings.getString('verifyOtp', context),
                    hintText: '123456',
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.getString('required', context);
                      }
                      if (value.length != 6) {
                        return AppStrings.getString('otpInvalid', context);
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                ],
                
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: _isOtpSent 
                        ? AppStrings.getString('verifyOtp', context)
                        : AppStrings.getString('sendOtp', context),
                    onPressed: _isLoading 
                        ? null 
                        : (_isOtpSent ? _verifyOtp : _sendOtp),
                    isLoading: _isLoading,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Reset Button (shown after OTP is sent)
                if (_isOtpSent)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isLoading ? null : _resetForm,
                      child: Text(
                        AppStrings.getString('back', context),
                        style: const TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 40),
                
                // Language Toggle
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.getString('language', context) + ': ',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => languageProvider.toggleLanguage(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            languageProvider.currentLanguageName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Error Display
                if (authProvider.error != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Text(
                      authProvider.error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}