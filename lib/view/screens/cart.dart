import 'package:flutter/material.dart';
import '../../model/book.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Book> Cart = [
    Book(
      bookid: 13,
      name: 'The Lean Startup',
      image: 'assets/images/The Lean Startup.png',
      author: 'Eric Ries',
      description: 'A revolutionary approach to business and innovation.',
      price: 2500,
      category: 'Business',
      condition: 'New',
      year: 2022,
      language: 'English',
      numberOfPages: 300,
      forWhat: 'Sell',
    ),
    Book(
      bookid: 14,
      name: 'The Naturalist',
      image: 'assets/images/The Naturalist.jpg',
      author: 'Andrew Mayne',
      description: 'A suspenseful thriller with a scientific twist.',
      price: 2300,
      category: 'Thriller',
      condition: 'New',
      year: 2020,
      language: 'English',
      numberOfPages: 290,
      forWhat: 'Sell',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: Cart.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.builder(
              itemCount: Cart.length,
              itemBuilder: (context, index) {
                final book = Cart[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        book.image,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(book.name),
                    subtitle: Text('Rs${book.price}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Remove the book from the cart
                        setState(() {
                          Cart.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${book.name} removed from cart'),
                          ),
                        );
                      },
                      child: const Text('Remove from Cart'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 60, 0),
                          foregroundColor: Colors.black // Button color
                          ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
