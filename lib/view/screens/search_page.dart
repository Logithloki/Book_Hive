// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../../model/book.dart';
import '../widgets/app_bar.dart';
import 'book_details.dart';
import 'cart.dart';
import 'profile.dart';
import 'about.dart';
import 'home.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int selectedIndex = 0; 
  void onPageSelected(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
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

  final List<Book> books = [
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
    ),
    Book(
      bookid: 7,
      name: 'Romeo and Juliet',
      image: 'assets/images/Romeo Juliet.jpg',
      author: 'William Shakespeare',
      description: 'The timeless love story of star-crossed lovers.',
      price: 1600,
      category: 'Drama',
      condition: 'Good',
      year: 2015,
      language: 'English',
      numberOfPages: 210,
      forWhat: 'Sell',
    ),
    Book(
      bookid: 8,
      name: 'Soul',
      image: 'assets/images/soul.jpg',
      author: 'Unknown',
      description: 'A deep dive into the essence of life and spirit.',
      price: 1800,
      category: 'Philosophy',
      condition: 'Fair',
      year: 2018,
      language: 'English',
      numberOfPages: 300,
      forWhat: 'Rent',
    ),
    Book(
      bookid: 9,
      name: 'Tempest',
      image: 'assets/images/Tempest.jpg',
      author: 'William Shakespeare',
      description: 'A dramatic tale of magic, betrayal, and revenge.',
      price: 1550,
      category: 'Drama',
      condition: 'Good',
      year: 2017,
      language: 'English',
      numberOfPages: 180,
      forWhat: 'Sell',
    ),
    Book(
      bookid: 10,
      name: 'The Grammar',
      image: 'assets/images/The Grammar.png',
      author: 'Unknown',
      description: 'A comprehensive guide to mastering language.',
      price: 1400,
      category: 'Education',
      condition: 'New',
      year: 2020,
      language: 'English',
      numberOfPages: 150,
      forWhat: 'Sell',
    ),
    Book(
      bookid: 11,
      name: 'The Half Known',
      image: 'assets/images/The half know.png',
      author: 'Unknown',
      description: 'A mystery novel filled with secrets and revelations.',
      price: 1750,
      category: 'Mystery',
      condition: 'Fair',
      year: 2019,
      language: 'English',
      numberOfPages: 340,
      forWhat: 'Rent',
    ),
    Book(
      bookid: 12,
      name: 'The House of Lost Secrets',
      image: 'assets/images/The House of Lost Secrets.jpg',
      author: 'Unknown',
      description: 'A thrilling adventure into the unknown.',
      price: 2100,
      category: 'Adventure',
      condition: 'Good',
      year: 2021,
      language: 'English',
      numberOfPages: 370,
      forWhat: 'Exchange',
    ),
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
    Book(
      bookid: 15,
      name: 'To Kill a Mockingbird',
      image: 'assets/images/To Kill a Mocking bird.png',
      author: 'Harper Lee',
      description: 'A dramatic tale of justice, race, and moral growth.',
      price: 1550,
      category: 'Fiction',
      condition: 'Good',
      year: 2019,
      language: 'English',
      numberOfPages: 281,
      forWhat: 'Exchange',
    ),
    Book(
      bookid: 10,
      name: 'The Grammar',
      image: 'assets/images/The Grammar.png',
      author: 'Unknown',
      description: 'A comprehensive guide to mastering language.',
      price: 1400,
      category: 'Education',
      condition: 'New',
      year: 2020,
      language: 'English',
      numberOfPages: 150,
      forWhat: 'Exchange',
    ),
    Book(
      bookid: 16,
      name: 'The Wide Wide Sea',
      image: 'assets/images/The wide wide sea.jpg',
      author: 'Eric Ries',
      description: 'An expansive tale about exploration and discovery.',
      price: 2500,
      category: 'Adventure',
      condition: 'Good',
      year: 2020,
      language: 'English',
      numberOfPages: 380,
      forWhat: 'Exchange',
    ),
    Book(
      bookid: 17,
      name: 'The Plan',
      image: 'assets/images/The Plan.png',
      author: 'Andrew Mayne',
      description: 'A suspenseful thriller with a scientific twist.',
      price: 2300,
      category: 'Thriller',
      condition: 'Fair',
      year: 2021,
      language: 'English',
      numberOfPages: 290,
      forWhat: 'Exchange',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage(
                                'assets/images/profile.jpg'), 
                          ),
                          SizedBox(
                              height: 6), 
                          const Text(
                            'Logith Sivakumar', 
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              height: 2), 
                          const Text(
                            'logithsivakum@email.com', 
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600
                ? 3
                : 2, // Responsive grid
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            Book book = books[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailsPage(book: book),
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
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10)),
                        child: Image.asset(
                          book.image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.name,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(book.author,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700])),
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
    );
  }
}
