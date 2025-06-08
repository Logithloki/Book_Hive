// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_store/view/screens/login.dart';
import 'package:book_store/view/screens/book_details.dart';
import 'package:book_store/view/screens/edit_book.dart'; // Add import for edit book page
import 'package:book_store/models/book.dart';
import 'package:book_store/services/auth_service.dart';
import 'package:book_store/services/book_service.dart'; // Add import for book service
import 'package:book_store/auth_helper.dart'; // Import auth helper
import 'package:book_store/widgets/theme_settings_widget.dart'; // Import theme settings widget

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _email = "";
  String _phone = "";
  String _location = "";
  String _password = "******";
  late Future<Map<String, dynamic>> _userDataFuture;
  // Key to force refresh the FutureBuilder for books
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late Future<List<Book>> _myBooksFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _loadUserData();
    _myBooksFuture = _loadMyBooks();
  }

  // Method to fetch user data from API
  Future<Map<String, dynamic>> _loadUserData() async {
    final result = await AuthService.getUser();

    if (result['success'] == true) {
      final userData = result['data'];
      // Update local variables for form fields
      setState(() {
        _name = userData['name'] ?? '';
        _email = userData['email'] ?? '';
        _phone = userData['phonenumber'] ?? '';
        _location = userData['location'] ?? '';
      });
      return userData;
    } else {
      throw Exception(result['message'] ?? 'Failed to load user data');
    }
  }

  // Method to load books with error handling
  Future<List<Book>> _loadMyBooks() async {
    try {
      print('Loading my books...');
      final result = await BookService.getMyBooks();
      print('BookService result: $result');

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        print('Data structure: ${data.runtimeType}');
        print('Data content: $data');

        List<dynamic> booksData;

        // Handle different response structures from your hybrid database
        if (data is List) {
          // Direct array of books
          booksData = data;
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is List) {
            // Paginated response with data array
            booksData = data['data'] as List<dynamic>;
          } else if (data.containsKey('books') && data['books'] is List) {
            // Response with books array
            booksData = data['books'] as List<dynamic>;
          } else {
            // Single book or unknown structure
            booksData = [data];
          }
        } else {
          print('Unexpected data type: ${data.runtimeType}');
          booksData = [];
        }

        print('Books data length: ${booksData.length}');

        final books = <Book>[];
        for (int i = 0; i < booksData.length; i++) {
          try {
            final bookJson = booksData[i];
            print('Processing book $i: $bookJson');

            if (bookJson is Map<String, dynamic>) {
              final book = Book.fromJson(bookJson);
              books.add(book);
            } else {
              print(
                  'Skipping invalid book data at index $i: ${bookJson.runtimeType}');
            }
          } catch (e) {
            print('Error parsing book at index $i: $e');
            // Continue with other books instead of failing completely
          }
        }

        print('Successfully parsed ${books.length} books');
        return books;
      } else if (result['html_error'] == true) {
        // If we received HTML instead of JSON, try to refresh the token
        print('Received HTML error, refreshing token...');
        await AuthHelper.refreshTokenIfNeeded(context);
        // Try again after token refresh
        return _loadMyBooks();
      } else {
        final errorMessage = result['message'] ?? 'Failed to load your books';
        print('API error: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error loading books: $e');
      throw Exception('Failed to load your books: $e');
    }
  }

  // Method to refresh books list
  Future<void> _refreshBooks() async {
    setState(() {
      _myBooksFuture = _loadMyBooks();
    });
  }

  // Method to handle logout
  Future<void> _handleLogout() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Logging out..."),
              ],
            ),
          );
        },
      );

      // Call logout API
      final result = await AuthService.logout();

      // Close loading dialog
      Navigator.of(context).pop();

      if (result['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        ); // Navigate to login page and clear navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Logout failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to refresh user data
  Future<void> _refreshUserData() async {
    setState(() {
      _userDataFuture = _loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshUserData,
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            tooltip: 'Refresh Profile',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading profile data...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshUserData,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            return _buildProfileForm(context, snapshot.data!);
          } else {
            return Center(
              child: Text('No data available'),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileForm(
      BuildContext context, Map<String, dynamic> userData) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Profile Section
              Column(
                children: <Widget>[
                  FadeInDown(
                    duration: Duration(milliseconds: 1000),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                  ),
                  SizedBox(height: 20),
                  FadeInDown(
                    duration: Duration(milliseconds: 1200),
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height: 20),
              Column(
                children: <Widget>[
                  FadeInDown(
                    duration: Duration(milliseconds: 1400),
                    child: TextFormField(
                      initialValue: _name,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _name = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  FadeInDown(
                    duration: Duration(milliseconds: 1500),
                    child: TextFormField(
                      initialValue: _email,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _email = value;
                        });
                      },
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value)) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  FadeInDown(
                    duration: Duration(milliseconds: 1600),
                    child: TextFormField(
                      initialValue: _phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _phone = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your phone number";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  FadeInDown(
                    duration: Duration(milliseconds: 1650),
                    child: TextFormField(
                      initialValue: _location,
                      decoration: InputDecoration(
                        labelText: "Location",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _location = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your location";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  FadeInDown(
                    duration: Duration(milliseconds: 1700),
                    child: TextFormField(
                      initialValue: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _password = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),

              FadeInDown(
                duration: Duration(milliseconds: 1800),
                child: Container(
                  padding: EdgeInsets.only(top: 3, left: 3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.black)),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // TODO: Implement actual profile update API call
                        _showSaveSuccessDialog();
                      }
                    },
                    color: Colors.orangeAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    child: Text(
                      "Save Changes",
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              _buildSuggestedBooks(context), SizedBox(height: 40),
              FadeInDown(
                duration: Duration(milliseconds: 1900),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Want to log out?"),
                    TextButton(
                      onPressed: _handleLogout,
                      child: Text(
                        'Log out',
                        style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              // Theme Settings Widget
              FadeInDown(
                duration: Duration(milliseconds: 2000),
                child: const ThemeSettingsWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSaveSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Profile updated successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuggestedBooks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Your Books",
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  fontWeight: FontWeight.w900),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Token',
              onPressed: () async {
                final success = await AuthHelper.refreshTokenIfNeeded(context);
                if (success) {
                  setState(() {
                    // Refresh state to reload books
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshBooks,
          child: FadeInDown(
            duration: Duration(milliseconds: 1500),
            child: FutureBuilder<List<Book>>(
              future: _myBooksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            AuthHelper.refreshTokenIfNeeded(context)
                                .then((_) => _refreshBooks());
                          },
                          child: const Text('Refresh Token'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('You haven\'t added any books yet'));
                } else {
                  // Use the book objects directly
                  final books = snapshot.data!;

                  return SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];

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
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: _buildBookImage(
                                    book.coverUrl,
                                    width: 120,
                                    height: 130,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Flexible(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditBookPage(book: book),
                                        ),
                                      );

                                      if (result == true) {
                                        // Refresh books list if book was updated
                                        setState(() {});
                                      }
                                    },
                                    child: Text('Edit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orangeAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
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
}
