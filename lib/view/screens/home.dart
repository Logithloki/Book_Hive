// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../widgets/book_section.dart';
import '../../models/book.dart';
import '../widgets/app_bar.dart';
import 'profile.dart';
import 'cart.dart';
import 'about.dart';
import 'add_book.dart';
import 'search_page.dart';
import 'connectivity_test.dart';
import '../../services/auth_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0; // Track the selected page index (0 = Home)
  List<Book> latestBooks = [];
  List<Book> exchangeBooks = [];
  bool isLoading = true;


  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _loadUserData();
    _loadBooks();
  }

  // Method to fetch user data from API
  Future<Map<String, dynamic>> _loadUserData() async {
    final result = await AuthService.getUser();

    if (result['success'] == true) {
      return result['data'];
    } else {
      // Return default user data if API fails
      return {
        'name': 'Guest User',
        'email': 'guest@example.com',
      };
    }
  }

  Future<void> _loadBooks() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch latest books and exchange books from API
      final latest = await Book.getLatestBooksAsync(limit: 10);
      final exchange = await Book.getExchangeBooksAsync(limit: 10);

      setState(() {
        latestBooks = latest;
        exchangeBooks = exchange;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading books: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

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
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: _userDataFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      AssetImage('assets/images/profile.jpg'),
                                ),
                                SizedBox(height: 6),
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Loading...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      AssetImage('assets/images/profile.jpg'),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Guest User',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Error loading profile',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            );
                          } else if (snapshot.hasData) {
                            final userData = snapshot.data!;
                            return SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage:
                                        AssetImage('assets/images/profile.jpg'),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    userData['name'] ?? 'Unknown User',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    userData['email'] ?? 'No email',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      AssetImage('assets/images/profile.jpg'),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Guest User',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'No Email Mentioned',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
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
                    ListTile(
                      leading: Icon(Icons.network_check, color: Colors.orange),
                      title: Text('Connectivity Test'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ConnectivityTestPage()),
                        );
                      },
                    ),
                  ],
                ),
              )
          : null, 
      body: isLoading 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading books...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadBooks,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none, 
                        children: [
                          Container(
                            height: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? MediaQuery.of(context).size.height * 0.45 
                                : MediaQuery.of(context).size.height * 0.5, 
                            width: MediaQuery.of(context).size.width / 1.3,
                            padding: EdgeInsets.all(16.0), 
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 150, 52), 
                              borderRadius: BorderRadius.circular(12.0), 
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
                                    ? MediaQuery.of(context).size.width / 2.5 
                                    : MediaQuery.of(context).size.width / 3, 
                                top: MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? MediaQuery.of(context).size.height / 6 
                                    : MediaQuery.of(context).size.height / 8, 
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 2, 
                                  height: MediaQuery.of(context).size.height / 3, 
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/images/homepage.jpg'), 
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
                      
                      // Latest Books Section
                      if (latestBooks.isNotEmpty) ...[
                        BookSection(title: 'LATEST BOOKS', books: latestBooks),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SearchPage()), 
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
                      ] else ...[
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'No latest books available',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                      ],

                      // Exchange Books Section  
                      if (exchangeBooks.isNotEmpty) ...[
                        BookSection(title: 'EXCHANGE BOOKS', books: exchangeBooks),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SearchPage()), 
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
                      ] else ...[
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'No exchange books available',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
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
