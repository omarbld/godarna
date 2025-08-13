import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

class AuthState {
  final Session? session;
  final UserProfile? profile;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    required this.session,
    required this.profile,
    required this.isLoading,
    required this.errorMessage,
  });

  AuthState copyWith({
    Session? session,
    UserProfile? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      session: session ?? this.session,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  static AuthState initial() => const AuthState(session: null, profile: null, isLoading: false, errorMessage: null);
}

class AuthNotifier extends StateNotifier<AuthState> {
  StreamSubscription<AuthStateChangeEvent>? _sub;
  String? _lastEmail;

  AuthNotifier() : super(AuthState.initial()) {
    _sub = supabase.auth.onAuthStateChange.listen((event) async {
      if (event.session != null) {
        await _loadProfile();
      } else {
        state = state.copyWith(session: null, profile: null);
      }
    });
    final session = supabase.auth.currentSession;
    if (session != null) {
      state = state.copyWith(session: session);
      _loadProfile();
    }
  }

  Future<void> disposeSub() async {
    await _sub?.cancel();
  }

  Future<void> sendOtpToEmail(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    _lastEmail = email;
    try {
      await supabase.auth.signInWithOtp(email: email, shouldCreateUser: true);
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> verifyEmailOtp(String token) async {
    if (_lastEmail == null) {
      state = state.copyWith(errorMessage: 'No email to verify');
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await supabase.auth.verifyOTP(
        type: OtpType.email,
        token: token,
        email: _lastEmail!,
      );
      await _loadProfile();
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    state = AuthState.initial();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final resp = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();
    final map = resp as Map<String, dynamic>?;
    if (map != null) {
      state = state.copyWith(session: supabase.auth.currentSession, profile: UserProfile.fromMap(map));
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());