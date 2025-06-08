import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/book.dart';
import '../../services/cart_service.dart';
import '../../services/auth_service.dart';

class BookDetailsPage extends StatefulWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  bool _showContactInfo = false;
  bool _isLoadingContact = false;
  Map<String, dynamic>? _ownerInfo;
  bool _isAddingToCart = false;

  Future<void> _toggleContactInfo() async {
    if (_showContactInfo) {
      setState(() {
        _showContactInfo = false;
      });
      return;
    }

    setState(() {
      _isLoadingContact = true;
    });
    try {
      if (widget.book.userId == null || widget.book.userId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner information not available')),
        );
        return;
      }

      final result = await AuthService.getUserById(widget.book.userId!);
      if (result['success'] == true) {
        setState(() {
          _ownerInfo = result['data'];
          _showContactInfo = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(result['message'] ?? 'Failed to load contact info')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading contact info: $e')),
      );
    } finally {
      setState(() {
        _isLoadingContact = false;
      });
    }
  }

  Future<void> _addToCart() async {
    if (widget.book.id == null || widget.book.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cannot add this book to cart: invalid book ID')),
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final result = await CartService.addToCart(widget.book.id!);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.book.title} added to cart!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to add book to cart'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (isPortrait)
                _buildPortraitView(context)
              else
                _buildLandscapeView(context),

              // Contact Information Section
              if (_showContactInfo) _buildContactInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              TextButton(
                onPressed: _toggleContactInfo,
                child: const Text('Hide'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_ownerInfo != null) ...[
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Name: ${_ownerInfo!['name'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Phone: ${_ownerInfo!['phonenumber'] ?? _ownerInfo!['phone'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            if (_ownerInfo!['email'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.email, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Email: ${_ownerInfo!['email']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ] else
            const Text('Contact information not available'),
        ],
      ),
    );
  }

  /// 📱 **Portrait Layout**
  Widget _buildPortraitView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Left-align text
      children: [
        // Centering the Book Image
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: widget.book.coverUrl,
              height: 250,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 250,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/Macbeth.jpg',
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10), // Left-aligned Book Details
        Text(
          widget.book.title,
          style: const TextStyle(
              fontFamily: 'Roboto', fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),

        Text(
          "LKR ${widget.book.price}",
          style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18,
              color: Colors.orange,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),

        Text(
          "By ${widget.book.author}",
          style: const TextStyle(
              fontFamily: 'Roboto', fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),

        Text(
          widget.book.description.isNotEmpty
              ? widget.book.description
              : "No description available.",
          style: const TextStyle(
              fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w400),
        ),

        const SizedBox(height: 16),

        // Additional Book Details
        _buildDetail("Category", widget.book.category),
        _buildDetail("Pages", "${widget.book.pages}"),
        _buildDetail("Condition", widget.book.condition),
        _buildDetail("Year", "${widget.book.year}"),
        _buildDetail("Language", widget.book.language),
        const SizedBox(height: 20), // Buttons: Add to Cart & Phone Number
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isAddingToCart ? null : _addToCart,
                icon: _isAddingToCart
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.shopping_cart, size: 18),
                label: Text(_isAddingToCart ? "Adding..." : "Add to Cart"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoadingContact ? null : _toggleContactInfo,
                icon: _isLoadingContact
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _showContactInfo ? Icons.visibility_off : Icons.phone,
                        size: 18),
                label: Text(_isLoadingContact
                    ? "Loading..."
                    : _showContactInfo
                        ? "Hide Contact"
                        : "Contact Info"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.shade200,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Suggested Books Section
        _buildSuggestedBooks(context),
      ],
    );
  }

  /// 💻 **Landscape Layout**
  Widget _buildLandscapeView(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Left Side: Book Image (Centered vertically)
            Expanded(
              flex: 4,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: widget.book.coverUrl,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/default_book.jpg',
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Right Side: Book Details (Left-aligned text)
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book.title,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),

                  Text(
                    "LKR ${widget.book.price}",
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),

                  Text(
                    "By ${widget.book.author}",
                    style: const TextStyle(
                        fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    widget.book.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(
                      height: 20), // Buttons: Add to Cart & Phone Number
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isAddingToCart ? null : _addToCart,
                          icon: _isAddingToCart
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.shopping_cart, size: 16),
                          label: Text(
                              _isAddingToCart ? "Adding..." : "Add to Cart"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _isLoadingContact ? null : _toggleContactInfo,
                          icon: _isLoadingContact
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  _showContactInfo
                                      ? Icons.visibility_off
                                      : Icons.phone,
                                  size: 16),
                          label: Text(_isLoadingContact
                              ? "Loading..."
                              : _showContactInfo
                                  ? "Hide"
                                  : "Contact"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Suggested Books Section
        _buildSuggestedBooks(context),
      ],
    );
  }

  Widget _buildSuggestedBooks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Suggested Books",
          style: TextStyle(
              fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),

        // Use FutureBuilder to load suggested books from API
        FutureBuilder<List<Book>>(
          future: Book.getLatestBooksAsync(limit: 6),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    'Error loading suggested books',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            }

            final suggestedBooks = snapshot.data ?? [];

            if (suggestedBooks.isEmpty) {
              return SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    'No suggested books available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: suggestedBooks.length,
                itemBuilder: (context, index) {
                  final suggestedBook = suggestedBooks[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookDetailsPage(book: suggestedBook),
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Left-align text
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: CachedNetworkImage(
                              imageUrl: suggestedBook.coverUrl,
                              width: 120,
                              height: 130,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 120,
                                height: 130,
                                color: Colors.grey[300],
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/default_book.jpg',
                                width: 120,
                                height: 130,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            suggestedBook.title,
                            style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
