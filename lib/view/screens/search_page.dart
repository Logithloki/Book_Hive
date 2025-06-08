// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:math';
import '../../models/book.dart';
import '../widgets/app_bar.dart';
import '../../services/microphone_service.dart';
import 'book_details.dart';
import 'cart.dart';
import 'profile.dart';
import 'about.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int selectedIndex = 0; // Track the selected page index (0 = Home)
  int currentPage = 0; // Current page of books
  int booksPerPage = 6; // Books per page - FIXED: This is already set to 6
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  final MicrophoneService _microphoneService = MicrophoneService();

  // Search bar and microphone variables
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isListening = false;
  bool _isSearching = false;
  Timer? _searchTimer;

  // Variables for shake detection
  double shakeThreshold = 2.7;
  int shakeSlopTimeMS = 500;
  int shakeCountResetTime = 3000;
  int shakeCount = 0;
  int lastShakeTime = 0;

  // Search and filter variables
  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];
  String _searchQuery = '';

  void onPageSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      ).then((_) => setState(() => selectedIndex = 0));
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CartPage()),
      ).then((_) => setState(() => selectedIndex = 0));
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AboutPage()),
      ).then((_) => setState(() => selectedIndex = 0));
    }
  }

  @override
  void initState() {
    super.initState();
    _startListeningToAccelerometer();
    _initializeBooks();
    _microphoneService.initialize();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchTimer?.cancel();
    _microphoneService.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    final query = _searchController.text;
    _searchTimer?.cancel();
    setState(() {
      _isSearching = true;
    });

    _searchTimer = Timer(Duration(milliseconds: 300), () {
      _performTextSearch(query);
      setState(() {
        _isSearching = false;
      });
    });
  }

  void _performTextSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBooks = List.from(_allBooks);
      } else {
        _filteredBooks = _allBooks.where((book) {
          final lowerQuery = query.toLowerCase();
          return book.title.toLowerCase().contains(lowerQuery) ||
              book.author.toLowerCase().contains(lowerQuery) ||
              book.category.toLowerCase().contains(lowerQuery) ||
              book.description.toLowerCase().contains(lowerQuery);
        }).toList();
      }
      currentPage = 0; // Reset to first page
    });
  }

  Future<void> _startVoiceSearch() async {
    if (_isListening) {
      _microphoneService.stopListening();
      setState(() {
        _isListening = false;
      });
      return;
    }

    setState(() {
      _isListening = true;
    });

    try {
      await _microphoneService.startListening(
        onResult: (text) {
          setState(() {
            _searchController.text = text;
            _isListening = false;
          });
          _performTextSearch(text);
        },
        onError: (error) {
          setState(() {
            _isListening = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Voice search error: $error')),
          );
        },
      );
    } catch (e) {
      setState(() {
        _isListening = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start voice search: $e')),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filteredBooks = List.from(_allBooks);
      currentPage = 0;
    });
  }

  void _initializeBooks() async {
    try {
      // Load books from the correct API endpoint: http://16.171.11.8/api/books
      // Load more books initially to have a good selection
      final response = await Book.getAllBooksAsync(page: 1, perPage: 20);
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _allBooks = (response['data'] as List)
              .map((bookData) => Book.fromJson(bookData))
              .toList();
          _filteredBooks = List.from(_allBooks);
        });
      } else {
        print(
            'Failed to load books: ${response['message'] ?? 'Unknown error'}');
        setState(() {
          _allBooks = [];
          _filteredBooks = [];
        });
      }
    } catch (e) {
      print('Error fetching books: $e');
      setState(() {
        _allBooks = [];
        _filteredBooks = [];
      });
    }
  } // Load more books when navigating to next page

  Future<void> _loadBooksForPage(int page) async {
    try {
      final response = await Book.getAllBooksAsync(page: page + 1, perPage: 20);
      if (response['success'] == true && response['data'] != null) {
        final newBooks = (response['data'] as List)
            .map((bookData) => Book.fromJson(bookData))
            .toList();

        // Add new books if they don't already exist
        for (var newBook in newBooks) {
          if (!_allBooks.any((book) => book.id == newBook.id)) {
            _allBooks.add(newBook);
          }
        }

        setState(() {
          _filteredBooks = List.from(_allBooks);
        });
      }
    } catch (e) {
      print('Error loading books for page $page: $e');
    }
  }

  Future<void> _refreshBooks() async {
    _initializeBooks();
  }

  void _startListeningToAccelerometer() {
    _accelerometerSubscription =
        accelerometerEventStream().listen((AccelerometerEvent event) {
      double gX = event.x / 9.80665;
      double gY = event.y / 9.80665;
      double gZ = event.z / 9.80665;

      double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

      if (gForce > shakeThreshold) {
        var now = DateTime.now().millisecondsSinceEpoch;
        if (lastShakeTime + shakeSlopTimeMS > now) {
          return;
        }

        if (lastShakeTime + shakeCountResetTime < now) {
          shakeCount = 0;
        }

        lastShakeTime = now;
        shakeCount++;

        if (shakeCount >= 2) {
          _goToNextPage();
          shakeCount = 0;
        }
      }
    });
  }

  void _goToNextPage() {
    setState(() {
      int totalPages = (_filteredBooks.length / booksPerPage).ceil();
      if (totalPages > 0) {
        int nextPage = (currentPage + 1) % totalPages;

        // FIXED: Load more books if needed when going to next page
        if (nextPage > currentPage &&
            (nextPage + 1) * booksPerPage > _allBooks.length) {
          _loadBooksForPage(nextPage);
        }

        currentPage = nextPage;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Page ${currentPage + 1} of ${(_filteredBooks.length / booksPerPage).ceil()}'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildBookImage(String imageUrl, {double? width, double? height}) {
    if (imageUrl.isEmpty) {
      return Image.asset(
        'assets/images/logo.jpg',
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }

    return imageUrl.startsWith('http')
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Image.asset(
              'assets/images/logo.jpg',
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            imageUrl.startsWith('assets/')
                ? imageUrl
                : 'assets/images/$imageUrl',
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/logo.jpg',
                width: width,
                height: height,
                fit: BoxFit.cover,
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (_filteredBooks.length / booksPerPage).ceil();
    if (totalPages == 0) totalPages = 1;

    int startIndex = currentPage * booksPerPage;
    int endIndex = (startIndex + booksPerPage > _filteredBooks.length)
        ? _filteredBooks.length
        : startIndex + booksPerPage;
    List<Book> currentBooks = _filteredBooks.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: CustomResponsiveAppBar(
        selectedIndex: selectedIndex,
        onTap: onPageSelected,
      ),
      drawer: MediaQuery.of(context).orientation == Orientation.portrait
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                    ),
                    child: Text(
                      'Navigation Menu',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  if (selectedIndex == 0)
                    ListTile(
                      leading: Icon(Icons.home),
                      title: Text('Home'),
                      onTap: () {
                        Navigator.pop(context);
                        onPageSelected(0);
                      },
                    ),
                  if (selectedIndex != 3)
                    ListTile(
                      leading: Icon(Icons.info),
                      title: Text('About'),
                      onTap: () {
                        Navigator.pop(context);
                        onPageSelected(3);
                      },
                    ),
                  if (selectedIndex != 1)
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        onPageSelected(1);
                      },
                    ),
                  if (selectedIndex != 2)
                    ListTile(
                      leading: Icon(Icons.shopping_cart),
                      title: Text('Cart'),
                      onTap: () {
                        Navigator.pop(context);
                        onPageSelected(2);
                      },
                    ),
                ],
              ),
            )
          : null,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search books by title, author, category...',
                      prefixIcon: Icon(Icons.search, color: Colors.orange),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: _clearSearch,
                            ),
                          IconButton(
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening ? Colors.red : Colors.orange,
                            ),
                            onPressed: _startVoiceSearch,
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.orange.withOpacity(0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Results Info
          if (_searchQuery.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Found ${_filteredBooks.length} books for "$_searchQuery"',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (_isSearching)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                ],
              ),
            ),

          // Voice Listening Indicator
          if (_isListening)
            Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Listening... Speak now',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Books grid - FIXED: Proper height calculation
          Expanded(
            child: currentBooks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No books available'
                              : 'No books found for "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          SizedBox(height: 8),
                          TextButton(
                            onPressed: _clearSearch,
                            child: Text('Clear Search'),
                          ),
                        ],
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 600 ? 3 : 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: currentBooks.length,
                      itemBuilder: (context, index) {
                        Book book = currentBooks[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailsPage(book: book),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                    child: _buildBookImage(
                                      book.coverUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        book.author,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),

          // Bottom Pagination Controls
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${currentPage + 1} of $totalPages',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_android,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Shake to navigate',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Pagination controls
                if (totalPages > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Previous button
                      Container(
                        decoration: BoxDecoration(
                          color: currentPage > 0
                              ? Colors.orange
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: currentPage > 0
                              ? () {
                                  setState(() {
                                    currentPage--;
                                  });
                                }
                              : null,
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: currentPage > 0 ? Colors.white : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),

                      SizedBox(width: 8),

                      // Page number buttons
                      ...List.generate(
                        totalPages > 5 ? 5 : totalPages,
                        (index) {
                          int pageIndex;
                          if (totalPages <= 5) {
                            pageIndex = index;
                          } else {
                            int start =
                                (currentPage - 2).clamp(0, totalPages - 5);
                            pageIndex = start + index;
                          }

                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            child: TextButton(
                              onPressed: () {
                                // FIXED: Load books for new page when manually navigating
                                if (pageIndex != currentPage) {
                                  if ((pageIndex + 1) * booksPerPage >
                                      _allBooks.length) {
                                    _loadBooksForPage(pageIndex);
                                  }
                                  setState(() {
                                    currentPage = pageIndex;
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: currentPage == pageIndex
                                    ? Colors.orange
                                    : Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: currentPage == pageIndex
                                        ? Colors.orange
                                        : Colors.grey.shade300,
                                  ),
                                ),
                              ),
                              child: Text(
                                '${pageIndex + 1}',
                                style: TextStyle(
                                  color: currentPage == pageIndex
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: currentPage == pageIndex
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      if (totalPages > 5 && currentPage < totalPages - 3)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('...',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 16)),
                        ),

                      SizedBox(width: 8),

                      // Next button
                      Container(
                        decoration: BoxDecoration(
                          color: currentPage < totalPages - 1
                              ? Colors.orange
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: currentPage < totalPages - 1
                              ? () {
                                  // FIXED: Load books when going to next page
                                  if ((currentPage + 2) * booksPerPage >
                                      _allBooks.length) {
                                    _loadBooksForPage(currentPage + 1);
                                  }
                                  setState(() {
                                    currentPage++;
                                  });
                                }
                              : null,
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: currentPage < totalPages - 1
                                ? Colors.white
                                : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: 8),

                // Page dots indicator
                if (totalPages <= 10 && totalPages > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalPages, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: currentPage == index ? 12 : 8,
                        height: currentPage == index ? 12 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentPage == index
                              ? Colors.orange
                              : Colors.grey[300],
                        ),
                      );
                    }),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
