// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';

class AuthService {
  // Base URL for API
  static const String baseUrl = 'http://16.171.11.8/api';

  // Save token to shared preferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Get token from shared preferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Remove token from shared preferences (for logout)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get authorization headers with token
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    print('===== Auth Headers =====');
    print('Token: ${token?.substring(0, math.min(token.length, 20))}...');
    print('Headers: $headers');
    print('========================');
    return headers;
  }

  // Login user
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      // Check connectivity before making request
      final connectivityService = ConnectivityService();
      final isConnected = await connectivityService.checkConnectivity();

      if (!isConnected) {
        return {
          'success': false,
          'message': connectivityService.getNoConnectivityMessage(),
          'error_type': 'connectivity',
        };
      }

      print('Attempting login to: $baseUrl/login');
      print('Email: $email');

      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              // Add CORS headers for web
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Methods': 'POST, GET, PUT, DELETE, OPTIONS',
              'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            },
            body: jsonEncode(<String, String>{
              'email': email,
              'password': password,
              'device_name': 'flutter-app',
            }),
          )
          .timeout(const Duration(seconds: 30));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Login successful!');
        // If login is successful, save the token
        if (responseData['token'] != null) {
          await saveToken(responseData['token']);
        }
        return {
          'success': true,
          'message': 'Login successful',
          'data': responseData
        };
      } else {
        print('Login failed with status: ${response.statusCode}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      print('Login error: $e');
      String errorMessage = 'Network error occurred';

      if (e.toString().contains('ClientException')) {
        errorMessage =
            'Unable to connect to server. Please check your internet connection.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (e.toString().contains('CORS')) {
        errorMessage =
            'CORS error. Please run the app on a mobile device or use a proxy.';
      }

      return {
        'success': false,
        'message': errorMessage,
        'error_details': e.toString(),
      };
    }
  }

  // Register user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phonenumber,
    required String location,
    String deviceName = 'flutter-app',
  }) async {
    try {
      // Check connectivity before making request
      final connectivityService = ConnectivityService();
      final isConnected = await connectivityService.checkConnectivity();

      if (!isConnected) {
        return {
          'success': false,
          'message': connectivityService.getNoConnectivityMessage(),
          'error_type': 'connectivity',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phonenumber': phonenumber,
          'location': location,
          'device_name': deviceName,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // If registration is successful and returns a token
        if (responseData['token'] != null) {
          await saveToken(responseData['token']);
        }
        return {
          'success': true,
          'message': responseData['message'] ?? 'Registration successful',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get current user profile
  static Future<Map<String, dynamic>> getUser() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get user data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get user by ID
  static Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      print('Getting user by ID: $userId');
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
      );

      print('getUserById response status: ${response.statusCode}');
      print('getUserById response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Check if the response has the expected structure
        if (responseData['success'] == true && responseData['data'] != null) {
          print('User data retrieved successfully: ${responseData['data']}');
          return {'success': true, 'data': responseData['data']};
        } else {
          // Handle case where API returns data directly without wrapper
          print('Direct user data response: $responseData');
          return {'success': true, 'data': responseData};
        }
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get user data',
        };
      }
    } catch (e) {
      print('getUserById error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Refresh token
  static Future<Map<String, dynamic>> refreshToken() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/refresh-token'),
        headers: headers,
        body: jsonEncode({'device_name': 'flutter-app'}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save the new token
        if (responseData['token'] != null) {
          await saveToken(responseData['token']);
        }
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to refresh token',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Logout user
  static Future<Map<String, dynamic>> logout() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );

      // Remove token regardless of API response
      await removeToken();

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Logged out successfully',
        };
      } else {
        return {
          'success':
              true, // Still consider it successful since we removed local token
          'message': 'Logged out locally',
        };
      }
    } catch (e) {
      // Even if network fails, remove local token
      await removeToken();
      return {
        'success': true,
        'message': 'Logged out locally',
      };
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
