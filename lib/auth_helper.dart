// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class AuthHelper {
  static Future<bool> refreshTokenIfNeeded(BuildContext context) async {
    // Check if token is available
    final token = await AuthService.getToken();
    if (token == null) {
      _showAuthError(
          context, 'No authentication token found. Please log in again.');
      return false;
    }

    // Try to refresh the token
    print('Attempting to refresh token...');
    final result = await AuthService.refreshToken();

    if (result['success']) {
      print('Token refreshed successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication refreshed successfully')),
      );
      return true;
    } else {
      print('Token refresh failed: ${result["message"]}');
      _showAuthError(
          context, result['message'] ?? 'Failed to refresh authentication');
      return false;
    }
  }

  static void _showAuthError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Logout',
          textColor: Colors.white,
          onPressed: () async {
            await AuthService.logout();
            // Navigate to login screen
            // Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
      ),
    );
  }
}
