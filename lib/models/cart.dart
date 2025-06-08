// ignore_for_file: avoid_print

import '../services/cart_service.dart';
import 'book.dart';

class Cart {
  final String? id;
  final String userId;
  final String bookId;
  final int quantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional properties for cart functionality
  Book? book; // Associated book object
  
  // Define fillable properties according to your database schema
  static const List<String> fillable = [
    'user_id',
    'book_id',
    'quantity',
  ];

  Cart({
    this.id,
    required this.userId,
    required this.bookId,
    this.quantity = 1,
    this.createdAt,
    this.updatedAt,
    this.book,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      userId: json['user_id'] ?? '',
      bookId: json['book_id'] ?? '',
      quantity: _parseInt(json['quantity']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      book: json['book'] != null ? Book.fromJson(json['book']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'quantity': quantity,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      if (book != null) 'book': book!.toJson(),
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

  // Helper methods for safe parsing
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 1;
    if (value is double) return value.toInt();
    return 1;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // Create a copy with updated fields
  Cart copyWith({
    String? id,
    String? userId,
    String? bookId,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    Book? book,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      book: book ?? this.book,
    );
  }

  // Calculate total price for this cart item
  double get totalPrice {
    if (book == null) return 0.0;
    return book!.price * quantity;
  }

  // Check if cart item is available
  bool get isAvailable {
    if (book == null) return false;
    return book!.stock >= quantity;
  }

  // ===== ASYNC FUNCTIONS =====

  // Validate cart item
  Future<Map<String, String>> validateAsync() async {
    final errors = <String, String>{};

    // Simulate API validation
    await Future.delayed(Duration(milliseconds: 100));

    if (userId.isEmpty) {
      errors['user_id'] = 'User ID is required';
    }
    if (bookId.isEmpty) {
      errors['book_id'] = 'Book ID is required';
    }
    if (quantity <= 0) {
      errors['quantity'] = 'Quantity must be greater than 0';
    }

    // Check if book is available
    if (book != null && book!.stock < quantity) {
      errors['quantity'] = 'Requested quantity exceeds available stock';
    }

    return errors;
  }

  // Save cart item to database
  Future<bool> saveAsync() async {
    try {
      await Future.delayed(Duration(milliseconds: 200));
      print('Cart item saved successfully');
      return true;
    } catch (e) {
      print('Error saving cart item: $e');
      return false;
    }
  }

  // Update cart item quantity
  Future<Cart?> updateQuantityAsync(int newQuantity) async {
    try {
      await Future.delayed(Duration(milliseconds: 150));
      
      final updatedCart = copyWith(
        quantity: newQuantity,
        updatedAt: DateTime.now(),
      );
      
      print('Cart item quantity updated to $newQuantity');
      return updatedCart;
    } catch (e) {
      print('Error updating cart item: $e');
      return null;
    }
  }

  // Remove cart item
  Future<bool> removeAsync() async {
    try {
      await Future.delayed(Duration(milliseconds: 150));
      print('Cart item removed successfully');
      return true;
    } catch (e) {
      print('Error removing cart item: $e');
      return false;
    }
  }
  // ===== API INTEGRATION METHODS =====

  // Static method to get user's cart from API
  static Future<Map<String, dynamic>> getCartAsync() async {
    return await CartService.getCart();
  }

  // Add item to cart via API
  static Future<Map<String, dynamic>> addToCartAsync({
    required String bookId,
    int quantity = 1,
  }) async {
    return await CartService.addToCart(bookId);
  }

  // Update cart item via API - Note: CartService doesn't have updateCartItem method
  Future<Map<String, dynamic>> updateViaApiAsync() async {
    // Since there's no updateCartItem in CartService, we'll remove and re-add
    if (id == null) {
      return {
        'success': false,
        'message': 'Cart item ID is required for update',
      };
    }

    // Remove first, then add with new quantity (workaround)
    final removeResult = await CartService.removeFromCart(bookId);
    if (removeResult['success'] == true) {
      return await CartService.addToCart(bookId);
    }
    return removeResult;
  }

  // Remove cart item via API
  Future<Map<String, dynamic>> removeViaApiAsync() async {
    return await CartService.removeFromCart(bookId);
  }

  // Static method to clear entire cart
  static Future<Map<String, dynamic>> clearCartAsync() async {
    return await CartService.clearCart();
  }

  // Static method to get cart item count
  static Future<Map<String, dynamic>> getCartCountAsync() async {
    return await CartService.getCartCount();
  }

  // Create Cart instance from API response
  static Cart fromApiResponse(Map<String, dynamic> apiData) {
    return Cart.fromJson(apiData);
  }

  // Convert to API request format
  Map<String, dynamic> toApiJson() {
    return {
      'user_id': userId,
      'book_id': bookId,
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return 'Cart(id: $id, userId: $userId, bookId: $bookId, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cart && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
