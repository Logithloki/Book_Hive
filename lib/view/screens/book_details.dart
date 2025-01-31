import 'package:flutter/material.dart';
import '../../model/book.dart';

class BookDetailsPage extends StatelessWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isPortrait
              ? _buildPortraitView(context)
              : _buildLandscapeView(context),
        ),
      ),
    );
  }

  Widget _buildPortraitView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Center(
          child: Image.asset(
            book.image,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),

        Text(
          book.name,
          style: const TextStyle(
              fontFamily: 'Roboto', fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),

        Text(
          "LKR ${book.price}",
          style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18,
              color: Colors.orange,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),

        Text(
          "By ${book.author}",
          style: const TextStyle(
              fontFamily: 'Roboto', fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),

        Text(
          book.description,
          style: const TextStyle(
              fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            _buildButton(context, "Add to Cart", Icons.shopping_cart,
                Colors.orangeAccent.shade200),
            const SizedBox(width: 10),
            _buildButton(context, "Phone Number", Icons.phone,
                Colors.blueAccent.shade200),
          ],
        ),
        const SizedBox(height: 20),

        _buildSuggestedBooks(context),
      ],
    );
  }

  Widget _buildLandscapeView(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Center(
                child: Image.asset(
                  book.image,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.name,
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 5),

                  Text(
                    "LKR ${book.price}",
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        color: Colors.orange,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),

                  Text(
                    "By ${book.author}",
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 17,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    book.description,
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _buildButton(context, "Add to Cart", Icons.shopping_cart,
                          Colors.green),
                      const SizedBox(width: 10),
                      _buildButton(
                          context, "Phone Number", Icons.phone, Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildSuggestedBooks(context),
      ],
    );
  }

  Widget _buildButton(
      BuildContext context, String text, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("$text clicked")));
      },
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
    );
  }

  Widget _buildSuggestedBooks(BuildContext context) {
    List<Book> suggestedBooks = [
      Book(
        bookid: 1,
        name: 'A Borrowed Path',
        image: 'assets/images/A Borrowed Path.jpg',
        author: 'Unknown',
        description: 'A journey of self-discovery and resilience.',
        price: 1800,
        category: 'Fiction',
        condition: 'Good',
        year: 2020,
        language: 'English',
        numberOfPages: 320,
        forWhat: 'Sell',
      ),
      Book(
        bookid: 2,
        name: 'Beautiful Lies',
        image: 'assets/images/Beautiful Lies.jpg',
        author: 'Lisa Unger',
        description: 'A gripping psychological thriller full of twists.',
        price: 2200,
        category: 'Thriller',
        condition: 'New',
        year: 2021,
        language: 'English',
        numberOfPages: 400,
        forWhat: 'Sell',
      ),
      Book(
        bookid: 3,
        name: 'Echo in Time',
        image: 'assets/images/Echo in time.jpg',
        author: 'Boo Walker',
        description:
            'A time travel romance that will have you on the edge of your seat!',
        price: 2000,
        category: 'Romance',
        condition: 'Fair',
        year: 2018,
        language: 'English',
        numberOfPages: 350,
        forWhat: 'Exchange',
      ),
      Book(
        bookid: 4,
        name: 'Echo of Old Book',
        image: 'assets/images/EchoofOldBook.jpg',
        author: 'Unknown',
        description: 'A story lost in the past, waiting to be rediscovered.',
        price: 1900,
        category: 'Mystery',
        condition: 'Poor',
        year: 2017,
        language: 'English',
        numberOfPages: 250,
        forWhat: 'Rent',
      ),
      Book(
        bookid: 5,
        name: 'Macbeth',
        image: 'assets/images/Macbeth.jpg',
        author: 'William Shakespeare',
        description: 'A classic tragedy of power, ambition, and fate.',
        price: 1500,
        category: 'Drama',
        condition: 'Good',
        year: 2015,
        language: 'English',
        numberOfPages: 180,
        forWhat: 'Sell',
      ),
      Book(
        bookid: 6,
        name: 'Never Ending Sky',
        image: 'assets/images/Never ending sky.jpg',
        author: 'Unknown',
        description: 'An inspiring tale of endless possibilities.',
        price: 1700,
        category: 'Fiction',
        condition: 'Good',
        year: 2019,
        language: 'English',
        numberOfPages: 310,
        forWhat: 'Exchange',
      )
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Suggested Books",
          style: TextStyle(
              fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),

        SizedBox(
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
                        CrossAxisAlignment.start, 
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          suggestedBook.image,
                          width: 120,
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        suggestedBook.name,
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
        ),
      ],
    );
  }
}
