import 'package:flutter/material.dart';
import '../../services/cart_service.dart';
import '../../models/cart.dart';
import '../../widgets/connectivity_status.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Cart> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await CartService.getCart();
      if (result['success'] == true) {
        final cartData = result['data']['items'] as List;
        setState(() {
          _cartItems.clear();
          _cartItems
              .addAll(cartData.map((item) => Cart.fromJson(item)).toList());
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load cart items';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading cart: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromCart(Cart cartItem) async {
    if (cartItem.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cannot remove this item: invalid cart ID')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await CartService.removeFromCart(cartItem.id!);

      if (result['success'] == true) {
        setState(() {
          _cartItems.removeWhere((item) => item.id == cartItem.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${cartItem.book?.title ?? 'Item'} removed from cart')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(result['message'] ?? 'Failed to remove item from cart')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showRemoveDialog(Cart cartItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove from Cart'),
          content: Text(
              'Are you sure you want to remove "${cartItem.book?.title ?? 'this item'}" from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeFromCart(cartItem);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookImage(String imageUrl, {double? width, double? height}) {
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.book,
          color: Colors.grey,
        ),
      );
    }

    return imageUrl.startsWith('http')
        ? Image.network(
            imageUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.book,
                  color: Colors.grey,
                ),
              );
            },
          )
        : Image.asset(
            imageUrl.startsWith('assets/')
                ? imageUrl
                : 'assets/images/$imageUrl',
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.book,
                  color: Colors.grey,
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityStatus(
      child: _buildCartContent(),
    );
  }

  Widget _buildCartContent() {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCartItems,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cart'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 20),
              Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Add some books to get started!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          final cartItem = _cartItems[index];
          final book = cartItem.book;
          return Dismissible(
            key: Key(cartItem.id ?? ''),
            onDismissed: (direction) => _removeFromCart(cartItem),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // Book Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildBookImage(
                        book?.coverUrl ?? '',
                        width: 60,
                        height: 80,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Book Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book?.title ?? 'Unknown Title',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'by ${book?.author ?? 'Unknown Author'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'LKR ${book?.price.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Remove Button
                    IconButton(
                      onPressed: () => _showRemoveDialog(cartItem),
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 24,
                      ),
                      tooltip: 'Remove from cart',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
