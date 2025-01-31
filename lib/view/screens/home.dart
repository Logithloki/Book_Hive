// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../../controller/book_controller.dart';
import '../widgets/book_section.dart';
import '../../model/book.dart';
import '../widgets/app_bar.dart';
import 'profile.dart';
import 'cart.dart';
import 'about.dart';
import 'add_book.dart';
import 'search_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final BookController controller = BookController();
  int selectedIndex = 0; // Track the selected page index (0 = Home)

  void onPageSelected(int index) {
    setState(() {
      selectedIndex = index;
    });

    // Navigate to the selected page
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

  @override
  Widget build(BuildContext context) {
    final List<Book> latestBooks = controller.fetchLatestBooks();
    final List<Book> exchangeBooks = controller.fetchExchangeBooks();

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
                  
                  if (selectedIndex != 0) 
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip
                    .none, 
                children: [
                  Container(
                    height: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.height *
                            0.45 
                        : MediaQuery.of(context).size.height *
                            0.5, 
                    width: MediaQuery.of(context).size.width /
                        1.3,
                    padding:
                        EdgeInsets.all(16.0), 
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 150,
                          52), 
                      borderRadius: BorderRadius.circular(
                          12.0), 
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        flex: 1, 
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'BOOK HIVE\nBookHive is a community-driven platform where users can '
                            'buy, sell, trade, and rent new or used books. Whether you\'re looking '
                            'to pass on your favorite reads, find a rare title, or rent textbooks, '
                            'BookHive makes it easy to connect with book lovers.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                      Positioned(
                        left: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? MediaQuery.of(context).size.width /
                                2.5 
                            : MediaQuery.of(context).size.width /
                                3, 
                        top: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? MediaQuery.of(context).size.height /
                                6 
                            : MediaQuery.of(context).size.height /
                                8, 
                        child: Container(
                          width: MediaQuery.of(context).size.width /
                              2, 
                          height: MediaQuery.of(context).size.height /
                              3, 
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/homepage.jpg'), 
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 30), 
              BookSection(title: 'LATEST BOOKS', books: latestBooks),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SearchPage()), 
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, 
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View More',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              SizedBox(height: 30), 

              BookSection(title: 'EXCHANGE BOOKS', books: exchangeBooks),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SearchPage()), 
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, 
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View More',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBookPage()),
          );
        },
        backgroundColor: Color.fromARGB(255, 255, 155, 24),
        child: Icon(Icons.add),
      ),
    );
  }
}
