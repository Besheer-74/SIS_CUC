import 'package:flutter/material.dart';

import '../../../core/config/supabase_config.dart';
import '../models/profile_model.dart';

class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileModel? _currentProfile;
  ProfileModel? get currentProfile => _currentProfile;

  bool get isLoggedIn => SupabaseConfig.currentUser != null;

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      await _loadUserProfile();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return;

      final data = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      _currentProfile = ProfileModel.fromJson(data);
    } catch (e) {
      debugPrint('Profile load error: $e');
    }
  }

  Future<void> logout() async {
    await SupabaseConfig.client.auth.signOut();
    _currentProfile = null;
    notifyListeners();
  }

  void clearError() => _errorMessage = null;
}