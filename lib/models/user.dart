// ignore_for_file: constant_identifier_names, prefer_const_constructors, avoid_print

import '../services/auth_service.dart';

class User {
  final String? id;
  final String name;
  final String email;
  final String phonenumber;
  final String location;
  final String password;
  final String payment; // Subscription plan: BASIC or PREMIUM

  static const String BASIC_PLAN = 'BASIC';
  static const String PREMIUM_PLAN = 'PREMIUM';

  bool get hasSubscription => payment.isNotEmpty;
  bool get isPremium => payment == PREMIUM_PLAN;

  // Define fillable properties according to your database schema
  static const List<String> fillable = [
    'name',
    'email',
    'phonenumber',
    'location',
    'password',
    'payment',
  ];

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phonenumber,
    required this.location,
    required this.password,
    required this.payment,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phonenumber: json['phonenumber'] ?? '',
      location: json['location'] ?? '',
      password: json['password'] ?? '',
      payment: json['payment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phonenumber': phonenumber,
      'location': location,
      'password': password,
      'payment': payment,
    };
  }

  // Helper method to convert to fillable data only
  Map<String, dynamic> toFillableJson() {
    final json = toJson();
    final fillableData = <String, dynamic>{};
    for (String field in fillable) {
      if (json.containsKey(field)) {
        fillableData[field] = json[field];
      }
    }
    return fillableData;
  }

  // Method to create User without sensitive data (for API responses)
  Map<String, dynamic> toSafeJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phonenumber': phonenumber,
      'location': location,
      'payment': payment,
      // Note: password is excluded for security
    };
  }

  // Helper method to update user with new data
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phonenumber,
    String? location,
    String? password,
    String? payment,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phonenumber: phonenumber ?? this.phonenumber,
      location: location ?? this.location,
      password: password ?? this.password,
      payment: payment ?? this.payment,
    );
  }

  // ===== ASYNC FUNCTIONS =====

  // Async method to validate user data
  Future<Map<String, String>> validateAsync() async {
    final errors = <String, String>{};

    // Simulate async validation (e.g., checking email availability)
    await Future.delayed(Duration(milliseconds: 150));

    if (name.trim().isEmpty) {
      errors['name'] = 'Name is required';
    }
    if (name.trim().length < 2) {
      errors['name'] = 'Name must be at least 2 characters';
    }

    // Email validation
    if (email.trim().isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errors['email'] = 'Please enter a valid email address';
    }

    // Phone number validation
    if (phonenumber.trim().isEmpty) {
      errors['phonenumber'] = 'Phone number is required';
    } else if (!RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phonenumber)) {
      errors['phonenumber'] = 'Please enter a valid phone number';
    }

    // Password validation
    if (password.length < 6) {
      errors['password'] = 'Password must be at least 6 characters';
    }

    return errors;
  }

  // Async method to check if email is available
  Future<bool> isEmailAvailableAsync() async {
    try {
      // Simulate API call to check email availability
      await Future.delayed(Duration(milliseconds: 500));

      // Simulate checking against database
      print('Checking email availability for: $email');

      // Simulate some emails being taken (for demo purposes)
      final takenEmails = [
        'admin@example.com',
        'test@test.com',
        'user@demo.com'
      ];
      final isAvailable = !takenEmails.contains(email.toLowerCase());

      return isAvailable;
    } catch (e) {
      print('Error checking email availability: $e');
      return false;
    }
  }

  // Async method to authenticate login
  Future<bool> authenticateAsync(String inputPassword) async {
    try {
      // Simulate async authentication process
      await Future.delayed(Duration(milliseconds: 300));

      // In real app, you'd hash the input password and compare
      // This is just for demonstration
      return password == inputPassword;
    } catch (e) {
      print('Error during authentication: $e');
      return false;
    }
  }

  // Async method to save user to database
  Future<bool> saveAsync() async {
    try {
      // Validate before saving
      final validationErrors = await validateAsync();
      if (validationErrors.isNotEmpty) {
        print('Validation failed: $validationErrors');
        return false;
      }

      // Check email availability
      final emailAvailable = await isEmailAvailableAsync();
      if (!emailAvailable) {
        print('Email already exists');
        return false;
      }

      // Simulate async database save operation
      await Future.delayed(Duration(milliseconds: 600));
      print('User "${name}" saved successfully');
      return true;
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  // Async method to update user profile
  Future<User?> updateProfileAsync(Map<String, dynamic> updates) async {
    try {
      // Create updated user
      final updatedUser = copyWith(
        name: updates['name'],
        email: updates['email'],
        phonenumber: updates['phonenumber'],
        location: updates['location'],
        payment: updates['payment'],
      );

      // Validate updated data
      final validationErrors = await updatedUser.validateAsync();
      if (validationErrors.isNotEmpty) {
        print('Profile update validation failed: $validationErrors');
        return null;
      }

      // If email changed, check availability
      if (updates['email'] != null && updates['email'] != email) {
        final emailAvailable = await updatedUser.isEmailAvailableAsync();
        if (!emailAvailable) {
          print('New email already exists');
          return null;
        }
      }

      // Simulate database update
      await Future.delayed(Duration(milliseconds: 400));
      print('Profile updated successfully');

      return updatedUser;
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  // Async method to change password
  Future<bool> changePasswordAsync(
      String currentPassword, String newPassword) async {
    try {
      // Verify current password
      final isCurrentPasswordValid = await authenticateAsync(currentPassword);
      if (!isCurrentPasswordValid) {
        print('Current password is incorrect');
        return false;
      }

      // Validate new password
      if (newPassword.length < 6) {
        print('New password must be at least 6 characters');
        return false;
      }

      // Simulate password update
      await Future.delayed(Duration(milliseconds: 300));
      print('Password changed successfully');
      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  // ===== API INTEGRATION METHODS =====

  // Static method to register a new user via API
  static Future<Map<String, dynamic>> registerAsync({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phonenumber,
    required String location,
  }) async {
    return await AuthService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      phonenumber: phonenumber,
      location: location,
    );
  }

  // Static method to login user via API
  static Future<Map<String, dynamic>> loginAsync({
    required String email,
    required String password,
  }) async {
    return await AuthService.login(email, password);
  }

  // Static method to get current user profile from API
  static Future<Map<String, dynamic>> getCurrentUserAsync() async {
    return await AuthService.getUser();
  }

  // Static method to logout user via API
  static Future<Map<String, dynamic>> logoutAsync() async {
    return await AuthService.logout();
  }

  // Static method to check if user is logged in
  static Future<bool> isLoggedInAsync() async {
    return await AuthService.isLoggedIn();
  }

  // Static method to refresh authentication token
  static Future<Map<String, dynamic>> refreshTokenAsync() async {
    return await AuthService.refreshToken();
  }

  // Create User instance from API response
  static User fromApiResponse(Map<String, dynamic> apiData) {
    return User(
      id: apiData['id']?.toString(),
      name: apiData['name'] ?? '',
      email: apiData['email'] ?? '',
      phonenumber: apiData['phonenumber'] ?? '',
      location: apiData['location'] ?? '',
      password: '', // Don't store password from API response
      payment: apiData['payment'] ?? '',
    );
  }

  // Convert to API request format for registration
  Map<String, dynamic> toRegistrationJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phonenumber': phonenumber,
      'location': location,
    };
  }
}
