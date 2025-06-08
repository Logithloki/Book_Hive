// book_section.dart

import 'package:flutter/material.dart';
import '../../models/book.dart'; // Import the new Book model
import '../screens/book_details.dart'; // Import book details page function

class BookSection extends StatelessWidget {
  final String title;
  final List<Book> books;
  const BookSection({super.key, required this.title, required this.books});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
                fontSize: 22,
                fontFamily: "Roboto",
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];

                return GestureDetector(
                  onTap: () {
                    // Navigate to book details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailsPage(
                            book: book), // Pass the whole book object
                      ),
                    );
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: _buildBookImage(
                            book.coverUrl,
                            width: 120,
                            height: 150,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              book.title,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookImage(String imageUrl, {double? width, double? height}) {
    print('DEBUG - BookSection _buildBookImage: imageUrl = "$imageUrl"');

    if (imageUrl.isEmpty) {
      print('DEBUG - BookSection: Empty imageUrl, showing book icon');
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.book,
          size: 40,
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
              print(
                  'DEBUG - BookSection: Network image failed for $imageUrl: $error');
              return Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.book,
                  size: 40,
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
              print(
                  'DEBUG - BookSection: Asset image failed for $imageUrl: $error');
              return Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.book,
                  size: 40,
                  color: Colors.grey,
                ),
              );
            },
          );
  }
}
