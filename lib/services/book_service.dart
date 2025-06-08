// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'connectivity_service.dart';

class BookService {
  // Base URL for API
  static const String baseUrl = 'http://16.171.11.8/api';

  // Valid book types and conditions
  static const List<String> validTypes = ['Sell', 'Rental', 'Exchange'];
  static const List<String> validConditions = ['New', 'Good', 'Fair', 'Poor'];

  // Helper method to validate book type
  static bool isValidType(String type) {
    return validTypes.contains(type);
  }

  // Helper method to validate book condition
  static bool isValidCondition(String condition) {
    return validConditions.contains(condition);
  }

  // Get all books with optional filtering and search
  static Future<Map<String, dynamic>> getAllBooks({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? search,
    int page = 1,
    int perPage = 20,
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

      // Build query parameters
      final queryParameters = {
        if (category != null) 'category': category,
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
        if (search != null) 'search': search,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final uri =
          Uri.parse('$baseUrl/books').replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: await AuthService.getAuthHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
          'meta': responseData['meta'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch books',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get books owned by the authenticated user
  static Future<Map<String, dynamic>> getMyBooks({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // Get the auth token and check if it's valid
      final token = await AuthService.getToken();
      if (token == null) {
        print('No authentication token found');
        return {
          'success': false,
          'message': 'Authentication token not found. Please log in again.',
        };
      }

      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      // Use the correct endpoint for my books
      final uri =
          Uri.parse('$baseUrl/my-books').replace(queryParameters: queryParams);

      print('Trying endpoint: $uri');
      final headers = await AuthService.getAuthHeaders();
      print('Request Headers: $headers');

      final response = await http.get(uri, headers: headers);

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      // Check if we received an HTML response instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        print(
            'Received HTML response instead of JSON. Authentication may have failed.');
        return {
          'success': false,
          'message': 'Authentication failed. Please log in again.',
          'html_error': true,
        };
      }
      try {
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          print('Successfully got books from my-books endpoint');
          print('Response data structure: ${responseData.runtimeType}');
          print(
              'Response data keys: ${responseData is Map ? responseData.keys : 'Not a Map'}');

          // Handle different response structures
          Map<String, dynamic> processedData;

          if (responseData is List) {
            // If API returns direct array of books
            processedData = {
              'data': responseData,
              'total': responseData.length,
              'current_page': page,
              'per_page': perPage,
            };
          } else if (responseData is Map<String, dynamic>) {
            // If API returns paginated structure
            if (responseData.containsKey('data')) {
              processedData = responseData;
            } else {
              // If the response is the books array wrapped in another structure
              processedData = {
                'data': responseData['books'] ?? responseData,
                'total': responseData['total'] ?? 0,
                'current_page': page,
                'per_page': perPage,
              };
            }
          } else {
            print('Unexpected response data type: ${responseData.runtimeType}');
            processedData = {
              'data': [],
              'total': 0,
              'current_page': page,
              'per_page': perPage,
            };
          }

          return {
            'success': true,
            'data': processedData,
          };
        } else {
          // Extract error message from API response
          final errorMessage =
              responseData['message'] ?? 'Failed to fetch your books';
          print('API returned error status: ${response.statusCode}');
          print('Error message from API: $errorMessage');
          return {
            'success': false,
            'message': errorMessage,
          };
        }
      } catch (jsonError) {
        print('JSON parsing error: $jsonError');
        print('Raw response body: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to parse API response: $jsonError',
        };
      }
    } catch (e) {
      print('Network error in getMyBooks: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get a specific book by ID
  static Future<Map<String, dynamic>> getBook(int bookId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/books/$bookId'),
        headers: await AuthService.getAuthHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch book',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Create a new book
  static Future<Map<String, dynamic>> createBook({
    required String title,
    required String author,
    required String isbn,
    required String category,
    required double price,
    required String condition,
    required String type,
    required int pages,
    required int year,
    required String language,
    String? description,
    String? image,
    int? rentalDays,
    String? exchangeCategory,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/books'),
        headers: await AuthService.getAuthHeaders(),
        body: jsonEncode({
          'title': title,
          'author': author,
          'isbn': isbn,
          'category': category,
          'price': price,
          'condition': condition,
          'type': type,
          'pages': pages,
          'year': year,
          'language': language,
          'description': description,
          'image': image,
          if (rentalDays != null) 'rental_days': rentalDays,
          if (exchangeCategory != null) 'exchange_category': exchangeCategory,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Book created successfully',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create book',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Update an existing book
  static Future<Map<String, dynamic>> updateBook({
    required dynamic bookId, // Can be int or String
    required String title,
    required String author,
    required String isbn,
    required String category,
    required double price,
    required String condition,
    required String type,
    required int pages,
    required int year,
    required String language,
    String? description,
    String? image,
    int? rentalDays,
    String? exchangeCategory,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/books/$bookId'),
        headers: await AuthService.getAuthHeaders(),
        body: jsonEncode(<String, dynamic>{
          'title': title,
          'author': author,
          'isbn': isbn,
          'category': category,
          'price': price,
          'condition': condition,
          'type': type,
          'pages': pages,
          'year': year,
          'language': language,
          if (description != null) 'description': description,
          if (image != null) 'image': image,
          if (rentalDays != null) 'rental_days': rentalDays,
          if (exchangeCategory != null) 'exchange_category': exchangeCategory,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Book updated successfully',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update book',
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

  // Delete a book
  static Future<Map<String, dynamic>> deleteBook(dynamic bookId) async {
    // Can be int or String
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/books/$bookId'),
        headers: await AuthService.getAuthHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Book deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete book',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Search books with advanced filters
  static Future<Map<String, dynamic>> searchBooks({
    required String query,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? sortBy,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {
        'search': query,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }
      if (condition != null && condition.isNotEmpty) {
        queryParams['condition'] = condition;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }

      final uri = Uri.parse('$baseUrl/books/search')
          .replace(queryParameters: queryParams);

      // Print debugging information
      print('Searching books with URL: $uri');

      final response = await http.get(
        uri,
        headers: await AuthService.getAuthHeaders(),
      );

      print('Response status code: ${response.statusCode}');

      // Check if response is HTML instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        print(
            'Received HTML response instead of JSON. Authentication may have failed.');
        // Try to refresh the token
        final refreshResult = await AuthService.refreshToken();
        if (refreshResult['success']) {
          // Try the request again with the new token
          return searchBooks(
            query: query,
            category: category,
            minPrice: minPrice,
            maxPrice: maxPrice,
            condition: condition,
            sortBy: sortBy,
            page: page,
            perPage: perPage,
          );
        } else {
          return {
            'success': false,
            'message': 'Authentication error. Please log in again.',
            'html_error': true,
          };
        }
      }

      try {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          return {'success': true, 'data': responseData};
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to search books',
          };
        }
      } catch (jsonError) {
        print('JSON parsing error: $jsonError');
        print(
            'Response body start: ${response.body.substring(0, math.min(response.body.length, 500))}');
        return {
          'success': false,
          'message': 'Failed to parse response: $jsonError',
        };
      }
    } catch (e) {
      print('Network error in searchBooks: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get books by category
  static Future<Map<String, dynamic>> getBooksByCategory({
    required String category,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      Map<String, String> queryParams = {
        'category': category,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final uri =
          Uri.parse('$baseUrl/books').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: await AuthService.getAuthHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to fetch books by category',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get featured/recommended books
  static Future<Map<String, dynamic>> getFeaturedBooks({
    int limit = 10,
  }) async {
    try {
      Map<String, String> queryParams = {
        'featured': 'true',
        'limit': limit.toString(),
      };

      final uri =
          Uri.parse('$baseUrl/books').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: await AuthService.getAuthHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to fetch featured books',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get latest books
  static Future<Map<String, dynamic>> getLatestBooks({
    int page = 1,
    int perPage = 20,
    int? limit,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': (limit ?? perPage).toString(),
      };

      final uri = Uri.parse('$baseUrl/books/latest')
          .replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: await AuthService.getAuthHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch latest books',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get exchange books
  static Future<Map<String, dynamic>> getExchangeBooks({
    int page = 1,
    int perPage = 20,
    int? limit,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': (limit ?? perPage).toString(),
      };

      final uri = Uri.parse('$baseUrl/books/exchange')
          .replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: await AuthService.getAuthHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to fetch exchange books',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get used books
  static Future<Map<String, dynamic>> getUsedBooks({
    int page = 1,
    int perPage = 20,
    int? limit,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': (limit ?? perPage).toString(),
      };

      final uri = Uri.parse('$baseUrl/books/used')
          .replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: await AuthService.getAuthHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch used books',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get rental books
  static Future<Map<String, dynamic>> getRentalBooks({
    int page = 1,
    int perPage = 20,
    int? limit,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': (limit ?? perPage).toString(),
        'type': 'Rental'
      };

      final uri = Uri.parse('$baseUrl/books/rental')
          .replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: await AuthService.getAuthHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch rental books',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Upload book image
  static Future<Map<String, dynamic>> uploadBookImage({
    required dynamic bookId, // Can be int or String
    required String imagePath,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/books/$bookId/image'),
      );

      request.headers.addAll(await AuthService.getAuthHeaders());
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Image uploaded successfully',
          'data': responseData
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to upload image',
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
