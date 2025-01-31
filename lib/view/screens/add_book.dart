import 'package:flutter/material.dart';
import 'dart:io';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  String _name = '';
  String _author = '';
  String _category = 'Fiction'; 
  String _condition = ''; 
  String _year = '';
  String _language = '';
  String _numberOfPages = '';
  String _for = 'Sell'; 

  final List<String> _categories = [
    'Fiction',
    'Non-Fiction',
    'Science',
    'History',
    'Biography'
  ];
  final List<String> _conditions = ['New', 'Good', 'Fair', 'Poor'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                child: _image == null
                    ? Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                            child: Text('Tap to select image',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0)))),
                      )
                    : Image.file(_image!),
              ),
              const SizedBox(height: 16.0),

              // Book name 
              TextFormField(
                decoration: const InputDecoration(labelText: 'Book Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the book name';
                  }
                  return null;
                },
                onChanged: (value) {
                  _name = value;
                },
              ),
              const SizedBox(height: 16.0),

              // Author 
              TextFormField(
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the author\'s name';
                  }
                  return null;
                },
                onChanged: (value) {
                  _author = value;
                },
              ),
              const SizedBox(height: 16.0),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              //radio buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _conditions.map((condition) {
                  return RadioListTile<String>(
                    title: Text(condition),
                    value: condition,
                    groupValue: _condition,
                    onChanged: (value) {
                      setState(() {
                        _condition = value!;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),

              // Year
              TextFormField(
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the year';
                  }
                  return null;
                },
                onChanged: (value) {
                  _year = value;
                },
              ),
              const SizedBox(height: 16.0),

              // Language 
              TextFormField(
                decoration: const InputDecoration(labelText: 'Language'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the language';
                  }
                  return null;
                },
                onChanged: (value) {
                  _language = value;
                },
              ),
              const SizedBox(height: 16.0),

              // Number of pages
              TextFormField(
                decoration: const InputDecoration(labelText: 'Number of Pages'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of pages';
                  }
                  return null;
                },
                onChanged: (value) {
                  _numberOfPages = value;
                },
              ),
              const SizedBox(height: 16.0),

              // radio buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ['Sell', 'Exchange', 'Rent'].map((option) {
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _for,
                    onChanged: (value) {
                      setState(() {
                        _for = value!;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String snackBarMessage = 'Book Name: $_name\n'
                        'Author: $_author\n'
                        'Category: $_category\n'
                        'Condition: $_condition\n'
                        'Year: $_year\n'
                        'Language: $_language\n'
                        'Number of Pages: $_numberOfPages\n'
                        'For: $_for';

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(snackBarMessage),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
                child: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
