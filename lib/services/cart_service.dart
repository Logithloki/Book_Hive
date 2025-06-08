import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'connectivity_service.dart';

class CartService {
  // Base URL for API
  static const String baseUrl = 'http://16.171.11.8/api';

  // Get cart items with totals
  static Future<Map<String, dynamic>> getCart() async {
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

      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: await AuthService.getAuthHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch cart',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Add book to cart
  static Future<Map<String, dynamic>> addToCart(String bookId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/add'),
        headers: await AuthService.getAuthHeaders(),
        body: jsonEncode({'book_id': bookId}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Book added to cart',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to add book to cart',
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

  // Remove book from cart
  static Future<Map<String, dynamic>> removeFromCart(String bookId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/remove'),
        headers: await AuthService.getAuthHeaders(),
        body: jsonEncode({'book_id': bookId}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Book removed from cart',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to remove book from cart',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Clear entire cart
  static Future<Map<String, dynamic>> clearCart() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/clear'),
        headers: await AuthService.getAuthHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Cart cleared successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to clear cart',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get cart item count
  static Future<Map<String, dynamic>> getCartCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart/count'),
        headers: await AuthService.getAuthHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get cart count',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Check if book is in cart
  static Future<Map<String, dynamic>> isBookInCart(String bookId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart/check/$bookId'),
        headers: await AuthService.getAuthHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to check cart',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Batch add multiple books to cart
  static Future<Map<String, dynamic>> addMultipleToCart(
      List<String> bookIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/add-multiple'),
        headers: await AuthService.getAuthHeaders(),
        body: jsonEncode({'book_ids': bookIds}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Books added to cart',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to add books to cart',
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

  // Batch remove multiple books from cart
  static Future<Map<String, dynamic>> removeMultipleFromCart(
      List<String> bookIds) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/remove-multiple'),
        headers: await AuthService.getAuthHeaders(),
        body: jsonEncode({'book_ids': bookIds}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Books removed from cart',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to remove books from cart',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Move cart to wishlist
  static Future<Map<String, dynamic>> moveToWishlist(String bookId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/move-to-wishlist'),
        headers: await AuthService.getAuthHeaders(),
        body: jsonEncode({'book_id': bookId}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Book moved to wishlist',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to move book to wishlist',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Validate cart before checkout
  static Future<Map<String, dynamic>> validateCart() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart/validate'),
        headers: await AuthService.getAuthHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Cart validation failed',
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
}
