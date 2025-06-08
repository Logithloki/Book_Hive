// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:io'; // For image handling
import 'package:image_picker/image_picker.dart';
import '../../services/book_service.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _title = '';
  String _author = '';
  String _category = 'Fiction'; // Default value
  String _condition = 'New'; // Default condition
  String _year = DateTime.now().year.toString();
  String _language = 'English';
  String _numberOfPages = '';
  String _for = 'Sell'; // Default listing type
  double _price = 0.0; // For Sell option
  int _rentalDays = 7; // For Rental option, default 7 days
  String _exchangeCategory = 'Fiction'; // For Exchange option
  bool _isLoading = false;
  // Categories list for the dropdown
  final List<String> _categories = [
    'Fiction',
    'Non-Fiction',
    'Science',
    'History',
    'Biography',
    'Romance'
  ];

  // Conditions for the book
  final List<String> _conditions = ['New', 'Good', 'Fair', 'Poor'];

  // Method to handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        // Create base book data
        final Map<String, dynamic> bookData = {
          'title': _title,
          'author': _author,
          'category': _category,
          'condition': _condition,
          'year': int.parse(_year),
          'language': _language,
          'pages': int.parse(_numberOfPages),
          'type': _for,
          'payment': 'cash', // Default payment method
          'description': '', // Default empty description
        }; // Add listing type specific data
        switch (_for) {
          case 'Sell':
            bookData['price'] = _price;
            bookData['rental_days'] = null;
            bookData['exchange_category'] = null;
            break;
          case 'Rent':
            bookData['price'] = 0.0;
            bookData['rental_days'] = _rentalDays;
            bookData['exchange_category'] = null;
            break;
          case 'Exchange':
            bookData['price'] = 0.0;
            bookData['rental_days'] = null;
            bookData['exchange_category'] = _exchangeCategory;
            break;
        } // Call the book service to create the book
        final result = await BookService.createBook(
          title: bookData['title'],
          author: bookData['author'],
          isbn: '', // Not required for now
          category: bookData['category'],
          price: bookData['price'] as double,
          condition: bookData['condition'],
          type: bookData['type'], // Pass the type field
          pages: bookData['pages'],
          year: bookData['year'],
          language: bookData['language'],
          description: bookData['description'],
          rentalDays: bookData['rental_days'],
          exchangeCategory: bookData['exchange_category'],
        );

        if (result['success'] == true) {
          // If book was created successfully and user selected an image, upload it
          if (_image != null && result['data'] != null) {
            final bookId =
                result['data']['id'] ?? result['data']['book']?['id'];
            if (bookId != null) {
              try {
                final imageResult = await BookService.uploadBookImage(
                  bookId: int.parse(bookId.toString()),
                  imagePath: _image!.path,
                );

                if (imageResult['success'] != true) {
                  print('Image upload failed: ${imageResult['message']}');
                  // Don't show error to user since book was created successfully
                }
              } catch (e) {
                print('Error uploading image: $e');
                // Don't show error to user since book was created successfully
              }
            }
          }

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to add book'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Book Image Section
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final XFile? image = await _picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            setState(() {
                              _image = File(image.path);
                            });
                          }
                        },
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _image!,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Add Book Cover',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter book title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the book title';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _title = value ?? '';
                      },
                    ),
                    const SizedBox(height: 20),

                    // Author Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Author',
                        hintText: 'Enter author name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the author name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _author = value ?? '';
                      },
                    ),
                    const SizedBox(height: 20),

                    // Condition Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Condition',
                        border: OutlineInputBorder(),
                      ),
                      value: _condition,
                      items: _conditions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _condition = value ?? 'New';
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: _category,
                      items: _categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _category = value ?? 'Fiction';
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Number of Pages Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Number of Pages',
                        hintText: 'Enter number of pages',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of pages';
                        }
                        final pages = int.tryParse(value);
                        if (pages == null || pages <= 0) {
                          return 'Please enter a valid number of pages';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _numberOfPages = value ?? '';
                      },
                    ),
                    const SizedBox(height: 20),

                    // Year Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Publication Year',
                        hintText: 'Enter publication year',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _year,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the publication year';
                        }
                        final year = int.tryParse(value);
                        if (year == null ||
                            year < 1800 ||
                            year > DateTime.now().year) {
                          return 'Please enter a valid year';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _year = value ?? DateTime.now().year.toString();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Language Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Language',
                        hintText: 'Enter book language',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _language,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the book language';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _language = value ?? 'English';
                      },
                    ),
                    const SizedBox(
                        height:
                            20), // Listing Type (Sell, Exchange, Rent) radio buttons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Listing Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Dynamic Fields based on Listing Type
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _for == 'Sell'
                          ? TextFormField(
                              key: const ValueKey('price'),
                              decoration: const InputDecoration(
                                labelText: 'Price (Rs)',
                                hintText: 'Enter selling price',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the price';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price <= 0) {
                                  return 'Please enter a valid price';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _price = double.tryParse(value ?? '0') ?? 0.0;
                              },
                            )
                          : _for == 'Rent'
                              ? TextFormField(
                                  key: const ValueKey('rental'),
                                  decoration: const InputDecoration(
                                    labelText: 'Rental Period (Days)',
                                    hintText: 'Enter rental period in days',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  keyboardType: TextInputType.number,
                                  initialValue: '7',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the rental period';
                                    }
                                    final days = int.tryParse(value);
                                    if (days == null || days <= 0) {
                                      return 'Please enter a valid number of days';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _rentalDays =
                                        int.tryParse(value ?? '7') ?? 7;
                                  },
                                )
                              : DropdownButtonFormField<String>(
                                  key: const ValueKey('exchange'),
                                  decoration: const InputDecoration(
                                    labelText: 'Preferred Exchange Category',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.category),
                                  ),
                                  value: _exchangeCategory,
                                  items: _categories.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _exchangeCategory = value ?? 'Fiction';
                                    });
                                  },
                                ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: _isLoading ? null : _submitForm,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Add Book',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
