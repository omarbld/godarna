import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:godarna/models/user_model.dart';
import 'package:godarna/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get isHost => _currentUser?.isHost ?? false;
  bool get isTenant => _currentUser?.isTenant ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Initialize auth state
  Future<void> initialize() async {
    try {
      _setLoading(true);
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Send OTP
  Future<bool> sendOtp(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _authService.sendOtp(email);
      if (success) {
        return true;
      } else {
        _setError('فشل في إرسال رمز التحقق');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP and sign in
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = await _authService.verifyOtp(email, otp);
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        _setError('رمز التحقق غير صحيح');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? language,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_currentUser == null) {
        _setError('المستخدم غير مسجل الدخول');
        return false;
      }

      final updatedUser = await _authService.updateProfile(
        userId: _currentUser!.id,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        language: language,
      );

      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      } else {
        _setError('فشل في تحديث الملف الشخصي');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change user role (for registration)
  Future<bool> changeRole(String role) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_currentUser == null) {
        _setError('المستخدم غير مسجل الدخول');
        return false;
      }

      final updatedUser = await _authService.changeRole(
        userId: _currentUser!.id,
        role: role,
      );

      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      } else {
        _setError('فشل في تغيير الدور');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
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