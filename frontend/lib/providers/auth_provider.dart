import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  // Getters
  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get isManager => _currentUser?.user.isManager ?? false;
  bool get isChef => _currentUser?.user.isChef ?? false;
  bool get isWaiter => _currentUser?.user.isWaiter ?? false;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setUser(AuthUser? user) {
    _currentUser = user;
    _isLoggedIn = user != null;
    notifyListeners();
  }

  // ðŸ”„ Enhanced: Initialize auth state with session restoration
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      // Try to restore saved session
      final restoredUser = await _authService.restoreSession();
      if (restoredUser != null) {
        _setUser(restoredUser);
      } else {
        // No valid session found
        _isLoggedIn = false;
      }
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create Restaurant (Manager)
  Future<bool> createRestaurant({
    required String restaurantName,
    required String address,
    required String phone,
    required String managerName,
    required String managerEmail,
    required String managerPassword,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.createRestaurant(
        restaurantName: restaurantName,
        address: address,
        phone: phone,
        managerName: managerName,
        managerEmail: managerEmail,
        managerPassword: managerPassword,
      );

      if (result.success) {
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to create restaurant: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Join Restaurant (Staff)
  Future<bool> joinRestaurant({
    required String restaurantCode,
    required String name,
    required String email,
    required String password,
    required JobType jobType,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.joinRestaurant(
        restaurantCode: restaurantCode,
        name: name,
        email: email,
        password: password,
        jobType: jobType,
      );

      if (result.success) {
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to join restaurant: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify Email
  Future<bool> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.verifyEmail(
        email: email,
        verificationCode: verificationCode,
      );

      if (result.success) {
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      _setError('Failed to verify email: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign In
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      if (result.success && result.data != null) {
        _setUser(result.data);
        if (result.data!.accessToken != null) {
          await _authService.saveAuthToken(result.data!.accessToken!);
        }
        return true;
      } else {
        _setError(result.error ?? 'Sign in failed');
        return false;
      }
    } catch (e) {
      _setError('Failed to sign in: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ðŸ”„ Enhanced: Sign Out with full data cleanup
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.clearUserData(); // Clear both token and user data
      _setUser(null);
    } catch (e) {
      _setError('Failed to sign out: $e');
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }
}
