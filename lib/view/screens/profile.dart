// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:book_store/view/screens/login.dart';
import 'package:book_store/view/screens/book_details.dart';
import 'package:book_store/model/book.dart';
import 'package:provider/provider.dart';
import 'package:book_store/themes/theme_manager.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _name = "Logith Sivakuar"; 
  String _email = "logithsivakumar@gmail.com"; 
  String _phone = "1234567890"; 
  String _password = "******"; 

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, 
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Theme.of(context).iconTheme.color ?? Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          width: double.infinity,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    FadeInDown(
                      duration: Duration(milliseconds: 1000),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            AssetImage('assets/images/profile.jpg'),
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
                        ),
                        onChanged: (value) {
                          setState(() {
                            _phone = value;
                          });
                        },
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length != 10) {
                            return "Please enter a valid 10-digit phone number";
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Changes saved successfully!'),
                            ),
                          );
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

                _buildSuggestedBooks(context),

                SizedBox(height: 40),

                FadeInDown(
                  duration: Duration(milliseconds: 1900),
                  child: ElevatedButton(
                    onPressed: () {
                      themeManager.toggleTheme();
                    },
                    child: Text(
                      themeManager.isDarkMode
                          ? 'Switch to Light Mode'
                          : 'Switch to Dark Mode',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent.shade200,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),

                SizedBox(height: 40),

                FadeInDown(
                  duration: Duration(milliseconds: 2000),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Want to log out?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
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
              ],
            ),
          ),
        ),
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
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Added Books",
          style: TextStyle(
              fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),
        FadeInDown(
          duration: Duration(milliseconds: 1500),
          child: SizedBox(
            height: 190,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Edit button clicked for ${suggestedBook.name}'),
                              ),
                            );
                          },
                          child: Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
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
      ],
    );
  }
}
