// ignore_for_file: avoid_print

import '../services/book_service.dart';

class Book {
  final String? id;
  final String title;
  final String author;
  final String category;
  final int pages;
  final String type; // Sell, Rental, Exchange
  final String condition;
  final int year;
  final String language;
  final String cover;
  final String payment;
  final double price;
  final int rentalDays;
  final String exchangeCategory;
  final String? userId;
  final int stock;
  final String description;
  final String? image;
  final String? isbn;

  // Legacy support properties (mapped to new properties)
  int get bookid => int.tryParse(id ?? '0') ?? 0;
  String get name => title;
  int get numberOfPages => pages;
  String get forWhat => type;
  String get coverUrl => image ?? cover;

  // Define fillable properties according to your database schema
  static const List<String> fillable = [
    'title',
    'author',
    'category',
    'pages',
    'type',
    'condition',
    'year',
    'language',
    'cover',
    'payment',
    'price',
    'rental_days',
    'exchange_category',
    'user_id',
    'stock',
    'description',
    'isbn',
    'image',
  ];

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.pages,
    required this.type,
    required this.condition,
    required this.year,
    required this.language,
    required this.cover,
    required this.payment,
    required this.price,
    required this.rentalDays,
    required this.exchangeCategory,
    this.userId,
    required this.stock,
    required this.description,
    this.image,
    this.isbn,
  });

  // Create Book from API response
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id']?.toString(),
      title: json['title'] ?? json['name'] ?? '',
      author: json['author'] ?? '',
      category: json['category'] ?? '',
      pages: _parseInt(json['pages'] ?? json['numberOfPages']),
      type: json['type'] ?? json['forWhat'] ?? 'Sell',
      condition: json['condition'] ?? 'Good',
      year: _parseInt(json['year']),
      language: json['language'] ?? 'English',
      cover: json['cover'] ?? json['image'] ?? '',
      payment: json['payment'] ?? 'pending',
      price: _parseDouble(json['price']),
      rentalDays: _parseInt(json['rental_days'] ?? json['rentalDays']),
      exchangeCategory: json['exchange_category'] ?? json['exchangeCategory'] ?? '',
      userId: json['user_id']?.toString(),
      stock: _parseInt(json['stock']),
      description: json['description'] ?? '',
      image: json['image'] ?? json['cover'],
      isbn: json['isbn'],
    );
  }

  // Legacy constructor for backward compatibility
  factory Book.legacy({
    required int bookid,
    required String name,
    required String image,
    required String author,
    required String description,
    required double price,
    required String category,
    required String condition,
    required int year,
    required String language,
    required int numberOfPages,
    required String forWhat,
  }) {
    return Book(
      id: bookid.toString(),
      title: name,
      author: author,
      category: category,
      pages: numberOfPages,
      type: forWhat,
      condition: condition,
      year: year,
      language: language,
      cover: image,
      payment: 'pending',
      price: price,
      rentalDays: 0,
      exchangeCategory: category,
      stock: 1,
      description: description,
      image: image,
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'category': category,
      'pages': pages,
      'type': type,
      'condition': condition,
      'year': year,
      'language': language,
      'cover': cover,
      'payment': payment,
      'price': price,
      'rental_days': rentalDays,
      'exchange_category': exchangeCategory,
      'user_id': userId,
      'stock': stock,
      'description': description,
      'image': image,
      'isbn': isbn,
    };
  }

  // Convert to fillable JSON format
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

  // Create from fillable data
  factory Book.fromFillableJson(Map<String, dynamic> json, [String? bookId]) {
    return Book(
      id: bookId ?? json['id']?.toString(),
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      category: json['category'] ?? '',
      pages: _parseInt(json['pages']),
      type: json['type'] ?? 'Sell',
      condition: json['condition'] ?? 'Good',
      year: _parseInt(json['year']),
      language: json['language'] ?? 'English',
      cover: json['cover'] ?? '',
      payment: json['payment'] ?? 'pending',
      price: _parseDouble(json['price']),
      rentalDays: _parseInt(json['rental_days']),
      exchangeCategory: json['exchange_category'] ?? '',
      userId: json['user_id']?.toString(),
      stock: _parseInt(json['stock']),
      description: json['description'] ?? '',
      image: json['image'] ?? json['cover'],
      isbn: json['isbn'],
    );
  }

  // Helper methods for safe parsing
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Create a copy with updated fields
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? category,
    int? pages,
    String? type,
    String? condition,
    int? year,
    String? language,
    String? cover,
    String? payment,
    double? price,
    int? rentalDays,
    String? exchangeCategory,
    String? userId,
    int? stock,
    String? description,
    String? image,
    String? isbn,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      pages: pages ?? this.pages,
      type: type ?? this.type,
      condition: condition ?? this.condition,
      year: year ?? this.year,
      language: language ?? this.language,
      cover: cover ?? this.cover,
      payment: payment ?? this.payment,
      price: price ?? this.price,
      rentalDays: rentalDays ?? this.rentalDays,
      exchangeCategory: exchangeCategory ?? this.exchangeCategory,
      userId: userId ?? this.userId,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      image: image ?? this.image,
      isbn: isbn ?? this.isbn,
    );
  }

  // ===== ASYNC FUNCTIONS =====

  // Validate book data
  Future<Map<String, String>> validateAsync() async {
    final errors = <String, String>{};

    // Simulate API validation
    await Future.delayed(Duration(milliseconds: 200));

    if (title.isEmpty) {
      errors['title'] = 'Title is required';
    }
    if (author.isEmpty) {
      errors['author'] = 'Author is required';
    }
    if (price < 0) {
      errors['price'] = 'Price cannot be negative';
    }
    if (pages <= 0) {
      errors['pages'] = 'Number of pages must be greater than 0';
    }
    if (year < 1000 || year > DateTime.now().year + 1) {
      errors['year'] = 'Please enter a valid year';
    }

    return errors;
  }

  // Save book to database
  Future<bool> saveAsync() async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      print('Book "${title}" saved successfully');
      return true;
    } catch (e) {
      print('Error saving book: $e');
      return false;
    }
  }

  // Update book data
  Future<Book?> updateAsync(Map<String, dynamic> updates) async {
    try {
      await Future.delayed(Duration(milliseconds: 400));
      
      final updatedBook = copyWith(
        title: updates['title']?.toString(),
        author: updates['author']?.toString(),
        category: updates['category']?.toString(),
        pages: updates['pages'] is int ? updates['pages'] : null,
        type: updates['type']?.toString(),
        condition: updates['condition']?.toString(),
        year: updates['year'] is int ? updates['year'] : null,
        language: updates['language']?.toString(),
        price: updates['price'] is double ? updates['price'] : null,
        description: updates['description']?.toString(),
      );
      
      print('Book "${title}" updated successfully');
      return updatedBook;
    } catch (e) {
      print('Error updating book: $e');
      return null;
    }
  }

  // ===== API INTEGRATION METHODS =====

  // Static method to get all books from API
  static Future<Map<String, dynamic>> getAllBooksAsync({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    return await BookService.getAllBooks(
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      search: search,
      page: page,
      perPage: perPage,
    );
  }

  // Static method to get user's books from API
  static Future<Map<String, dynamic>> getMyBooksAsync() async {
    return await BookService.getMyBooks();
  }

  // Static method to get specific book by ID
  static Future<Map<String, dynamic>> getBookAsync(int bookId) async {
    return await BookService.getBook(bookId);
  }
  // Static method to search books
  static Future<Map<String, dynamic>> searchBooksAsync(String query) async {
    return await BookService.searchBooks(query: query);
  }

  // Static method to get latest books
  static Future<List<Book>> getLatestBooksAsync({int limit = 10}) async {
    final result = await BookService.getLatestBooks(limit: limit);
    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      List<dynamic> booksData;
      
      if (data is List) {
        booksData = data;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        booksData = data['data'];
      } else {
        booksData = [];
      }
      
      return booksData.map((json) => Book.fromJson(json)).toList();
    }
    return [];
  }

  // Static method to get exchange books
  static Future<List<Book>> getExchangeBooksAsync({int limit = 10}) async {
    final result = await BookService.getExchangeBooks(limit: limit);
    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      List<dynamic> booksData;
      
      if (data is List) {
        booksData = data;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        booksData = data['data'];
      } else {
        booksData = [];
      }
      
      return booksData.map((json) => Book.fromJson(json)).toList();
    }
    return [];
  }

  // Create book via API
  Future<Map<String, dynamic>> createViaApiAsync() async {
    return await BookService.createBook(
      title: title,
      author: author,
      isbn: isbn ?? '',
      category: category,
      price: price,
      condition: condition,
      description: description,
      image: image,
    );
  }

  // Update book via API
  Future<Map<String, dynamic>> updateViaApiAsync() async {
    final bookId = int.tryParse(id ?? '0') ?? 0;
    if (bookId <= 0) {
      return {
        'success': false,
        'message': 'Invalid book ID',
      };
    }

    return await BookService.updateBook(
      bookId: bookId,
      title: title,
      author: author,
      isbn: isbn ?? '',
      category: category,
      price: price,
      condition: condition,
      description: description,
      image: image,
    );
  }

  // Delete book via API
  Future<Map<String, dynamic>> deleteViaApiAsync() async {
    final bookId = int.tryParse(id ?? '0') ?? 0;
    if (bookId <= 0) {
      return {
        'success': false,
        'message': 'Invalid book ID',
      };
    }

    return await BookService.deleteBook(bookId);
  }

  // Create Book instance from API response
  static Book fromApiResponse(Map<String, dynamic> apiData) {
    return Book.fromJson(apiData);
  }

  // Convert to API request format
  Map<String, dynamic> toApiJson() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'category': category,
      'price': price,
      'condition': condition,
      'description': description,
      'image': image,
      'pages': pages,
      'type': type,
      'year': year,
      'language': language,
      'rental_days': rentalDays,
      'exchange_category': exchangeCategory,
      'stock': stock,
    };
  }

  @override
  String toString() {
    return 'Book(id: $id, title: $title, author: $author, price: \$${price.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
