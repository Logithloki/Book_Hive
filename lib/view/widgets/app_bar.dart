// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_store/themes/theme_manager.dart';

class CustomResponsiveAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int selectedIndex;
  final Function(int)? onTap;

  CustomResponsiveAppBar({
    required this.selectedIndex,
    this.onTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    var isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: themeManager
          .currentTheme.appBarTheme.backgroundColor, // Dynamic theme applied
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logo.jpg',
                height: 24,
              ),
              SizedBox(width: 8),
              Text(
                'BOOK HIVE',
                style: TextStyle(
                  color: themeManager.currentTheme.appBarTheme
                      .foregroundColor, 
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isLandscape)
            Row(
              children: [
                if (selectedIndex != 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextButton(
                      onPressed: () {
                        if (onTap != null) onTap!(0);
                      },
                      child: Text(
                        'Home',
                        style: TextStyle(
                            color: themeManager.currentTheme.iconTheme
                                .color), 
                      ),
                    ),
                  ),
                if (selectedIndex != 3)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextButton(
                      onPressed: () {
                        if (onTap != null) onTap!(3);
                      },
                      child: Text(
                        'About',
                        style: TextStyle(
                            color: themeManager.currentTheme.iconTheme
                                .color), 
                      ),
                    ),
                  ),
              ],
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search,
                      color: themeManager.currentTheme.iconTheme
                          .color), 
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: themeManager.currentTheme
                      .scaffoldBackgroundColor, 
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (!isLandscape) 
          Builder(builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.orange),
              onPressed: () {
                Scaffold.of(context).openDrawer(); 
              },
            );
          }),
        if (selectedIndex != 1) 
          IconButton(
            icon: Icon(Icons.person, color: Colors.orange),
            onPressed: () {
              if (onTap != null) onTap!(1); 
            },
          ),
        if (selectedIndex != 2) 
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.orange),
            onPressed: () {
              if (onTap != null) onTap!(2); 
            },
          ),
      ],
    );
  }
}
