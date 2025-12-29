import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isAuthenticated = false;
  User? _currentUser;
  final Map<String, User> _registeredUsers = {};
  final Map<String, bool> _hasSeenOnboarding = {}; // Track onboarding status

  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  
  // Check if user has seen onboarding
  bool hasSeenOnboarding(String userId) {
    return _hasSeenOnboarding[userId] ?? false;
  }
  
  // Mark onboarding as completed
  void completeOnboarding(String userId) {
    _hasSeenOnboarding[userId] = true;
    notifyListeners();
  }
  
  // Mark onboarding as completed for current user
  void completeOnboardingForCurrentUser() {
    if (_currentUser != null) {
      completeOnboarding(_currentUser!.id);
    }
  }

  // Simulate login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      final emailKey = email.toLowerCase();
      
      // Check if email is empty or password is empty
      if (email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Email dan password harus diisi',
        };
      }
      
      // Check if user exists in registered users
      if (_registeredUsers.containsKey(emailKey)) {
        final registeredUser = _registeredUsers[emailKey]!;
        
        // Validate password
        if (registeredUser.password != null && registeredUser.password != password) {
          print('Password incorrect for: $emailKey');
          return {
            'success': false,
            'message': 'Password yang Anda masukkan salah',
          };
        }
        
        // Password correct or not set (for backward compatibility)
        _isAuthenticated = true;
        _currentUser = registeredUser;
        notifyListeners();
        print('Login successful for: $emailKey');
        return {
          'success': true,
          'message': 'Login berhasil',
        };
      } else {
        // User not found - create temporary user (for demo purposes)
        print('User not found, creating temporary user: $emailKey');
        _isAuthenticated = true;
        _currentUser = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _getNameFromEmail(email),
          email: email,
        );
        notifyListeners();
        return {
          'success': true,
          'message': 'Login berhasil',
        };
      }
    } catch (e) {
      print('Error during login: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan',
      };
    }
  }

  // Simulate registration
  Future<String> register(String name, String email, String password) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      final emailKey = email.toLowerCase();
      
      // Debug: Print registered users
      print('Registered users: ${_registeredUsers.keys}');
      print('Checking email: $emailKey');
      
      // Check if email already exists
      if (_registeredUsers.containsKey(emailKey)) {
        print('Email exists! Returning EMAIL_EXISTS');
        return 'EMAIL_EXISTS'; // Email sudah terdaftar
      }
      
      // Simple validation - in real app, this would be API call
      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        // Store registered user with password
        final newUser = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          email: email,
          password: password, // Simpan password
          isNewUser: true, // Tandai sebagai user baru
        );
        _registeredUsers[emailKey] = newUser;
        
        // User baru belum melihat onboarding
        _hasSeenOnboarding[newUser.id] = false;
        
        // Auto-login setelah registrasi
        _isAuthenticated = true;
        _currentUser = newUser;
        notifyListeners();
        
        print('User registered successfully: $emailKey with password');
        print('Current user set to: ${newUser.name}');
        // In real app, you would create account on server
        return 'SUCCESS';
      }
      return 'ERROR';
    } catch (e) {
      print('Error during registration: $e');
      return 'ERROR';
    }
  }

  // Demo login - skip authentication
  void demoLogin() {
    _isAuthenticated = true;
    _currentUser = User(
      id: 'demo',
      name: 'Sarah Amanda',
      email: 'sarah.amanda@email.com',
    );
    notifyListeners();
  }

  // Verify password for current user
  Future<bool> verifyPassword(String email, String password) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final emailKey = email.toLowerCase();
      final user = _registeredUsers[emailKey];
      
      if (user == null) return false;
      
      return user.password == password;
    } catch (e) {
      print('Error verifying password: $e');
      return false;
    }
  }

  // Update password for user
  Future<bool> updatePassword(String email, String newPassword) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final emailKey = email.toLowerCase();
      final user = _registeredUsers[emailKey];
      
      if (user == null) return false;
      
      // Update password
      final updatedUser = User(
        id: user.id,
        name: user.name,
        email: user.email,
        password: newPassword,
        isNewUser: user.isNewUser,
      );
      
      _registeredUsers[emailKey] = updatedUser;
      
      // Update current user if it's the same
      if (_currentUser?.email.toLowerCase() == emailKey) {
        _currentUser = updatedUser;
      }
      
      notifyListeners();
      print('Password updated successfully for: $emailKey');
      return true;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }

  // Logout
  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  // Forgot password
  Future<bool> resetPassword(String email) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In real app, this would send reset email
      return email.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Helper method to extract name from email
  String _getNameFromEmail(String email) {
    String username = email.split('@')[0];
    
    // Jika username hanya angka atau kurang dari 3 karakter, return "User"
    if (username.isEmpty || username.length < 3 || RegExp(r'^\d+$').hasMatch(username)) {
      return 'User';
    }
    
    // Convert to title case
    return username
        .split('.')
        .map((word) => word.isNotEmpty 
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word)
        .join(' ');
  }

  // Check if user is logged in (for app initialization)
  Future<void> checkAuthStatus() async {
    // In real app, you would check stored tokens/session
    // For demo, we'll assume not authenticated initially
    await Future.delayed(const Duration(milliseconds: 500));
    // Could check SharedPreferences, secure storage, etc.
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final String? password; // Tambahkan field password
  final bool isNewUser; // Tandai user baru

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.password, // Password optional untuk backward compatibility
    this.isNewUser = false, // Default false
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'password': password,
      'isNewUser': isNewUser,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profilePicture'],
      password: json['password'],
      isNewUser: json['isNewUser'] ?? false,
    );
  }
}