// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isLandscape = constraints.maxWidth > constraints.maxHeight;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'About Us',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 20),
                  isLandscape
                      // Landscape 
                      ? Row(
                          children: [
                            // Image
                            Expanded(
                              flex: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/pexels-rafael-cosquiere-1059286-2041540.jpg',
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            // Description
                            Expanded(
                              flex: 6,
                              child: Text(
                                "Welcome to BookHive, your ultimate platform for discovering, sharing, and trading books! At BookHive, we connect book lovers, making it easy to buy, sell, trade, or rent books while promoting sustainability through reuse. Our platform caters to all readers, from casual enthusiasts to collectors, offering a wide range of books across genres. With a subscription model for sellers and renters, we provide a fair, transparent, and user-friendly marketplace to keep books circulating and accessible.\n\nJoin BookHive to be part of a thriving community where stories are shared, knowledge is passed on, and the love for books continues to grow!",
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        )
                      // Portrait 
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/pexels-rafael-cosquiere-1059286-2041540.jpg',
                                width: double.infinity,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 20),
                            // Description
                            Text(
                              "Welcome to BookHive, your ultimate platform for discovering, sharing, and trading books! At BookHive, we connect book lovers, making it easy to buy, sell, trade, or rent books while promoting sustainability through reuse. Our platform caters to all readers, from casual enthusiasts to collectors, offering a wide range of books across genres. With a subscription model for sellers and renters, we provide a fair, transparent, and user-friendly marketplace to keep books circulating and accessible.\n\nJoin BookHive to be part of a thriving community where stories are shared, knowledge is passed on, and the love for books continues to grow!",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
