// import 'package:firebase_auth/firebase_auth.dart'; // ปิดไว้ก่อน
// import 'package:cloud_firestore/cloud_firestore.dart'; // ปิดไว้ก่อน
import '../../domain/entities/user_model.dart';
import '../../core/config/app_config.dart';

/// AuthRepository - ใช้ Mock Authentication (ไม่ใช้ Firebase)
/// จะเปิดใช้ Firebase ทีหลัง
class AuthRepository {
  // Mock current user
  UserModel? _currentUser;
  
  UserModel? get currentUser => _currentUser;
  Stream<UserModel?> get authStateChanges => Stream.value(_currentUser);
  
  // Mock Sign in with email and password
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Mock delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Check mock credentials
      if (password.isNotEmpty && email.isNotEmpty) {
        final role = AppConfig.adminEmails.contains(email)
            ? UserRole.admin
            : UserRole.client;
        
        _currentUser = UserModel(
          id: 'mock_${email.hashCode}',
          email: email,
          displayName: email.split('@').first,
          role: role,
        );
        
        return _currentUser;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }
  
  // Mock Sign up with email and password
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Mock delay
      await Future.delayed(const Duration(seconds: 1));
      
      final role = AppConfig.adminEmails.contains(email)
          ? UserRole.admin
          : UserRole.client;
      
      _currentUser = UserModel(
        id: 'mock_${email.hashCode}',
        email: email,
        displayName: displayName ?? email.split('@').first,
        role: role,
      );
      
      return _currentUser;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }
  
  // Mock Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return _currentUser;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      if (_currentUser != null && _currentUser!.id == user.id) {
        _currentUser = user;
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
  
  // Mock Update user role (admin only)
  Future<void> updateUserRole(String uid, UserRole role) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_currentUser?.id == uid) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          displayName: _currentUser!.displayName,
          role: role,
        );
      }
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }
  
  // Mock Get all users (admin only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // Return mock users list
      return [
        if (_currentUser != null) _currentUser!,
        UserModel(
          id: 'mock_user_1',
          email: 'user1@example.com',
          displayName: 'User One',
          role: UserRole.client,
        ),
        UserModel(
          id: 'mock_user_2',
          email: 'user2@example.com',
          displayName: 'User Two',
          role: UserRole.client,
        ),
      ];
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }
  
  // Mock Sign out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }
  
  // Mock Reset password
  Future<void> resetPassword(String email) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      // Mock success
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }
}
