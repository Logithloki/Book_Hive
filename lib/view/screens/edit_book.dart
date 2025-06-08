// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:io'; // For image handling
import 'package:image_picker/image_picker.dart';
import '../../services/book_service.dart';
import '../../models/book.dart';

class EditBookPage extends StatefulWidget {
  final Book book;

  const EditBookPage({super.key, required this.book});

  @override
  _EditBookPageState createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  late String _title;
  late String _author;
  late String _category;
  late String _condition;
  late String _year;
  late String _language;
  late String _numberOfPages;
  late String _for;
  late double _price;
  late int _rentalDays;
  late String _exchangeCategory;
  late String _description;
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
  @override
  void initState() {
    super.initState();
    // Debug: Print all book information
    print('=== EditBookPage Debug Info ===');
    print('Book ID: "${widget.book.id}"');
    print('Book ID type: ${widget.book.id.runtimeType}');
    print('Book bookid getter: ${widget.book.bookid}');
    print('Book title: "${widget.book.title}"');
    print('===============================');

    _title = widget.book.title;
    _author = widget.book.author;
    _category = widget.book.category;
    _condition = widget.book.condition;
    _year = widget.book.year.toString();
    _language = widget.book.language;
    _numberOfPages = widget.book.pages.toString();
    _for = widget.book.type;
    _price = widget.book.price;
    _rentalDays = widget.book.rentalDays;
    _exchangeCategory = widget.book.exchangeCategory;
    _description = widget.book.description;
  }

  // Method to handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });
      try {
        // Debug: Print the book ID and type
        print('=== Update Book Debug Info ===');
        print('Book ID from widget.book.id: "${widget.book.id}"');
        print('Book ID type: ${widget.book.id.runtimeType}');
        print('===============================');

        // Use the string ID directly
        final bookId = widget.book.id;

        if (bookId == null || bookId.isEmpty) {
          throw Exception('Invalid book ID: book ID is null or empty');
        }

        // Create base book data for update
        final Map<String, dynamic> bookData = {
          'title': _title,
          'author': _author,
          'category': _category,
          'condition': _condition,
          'year': int.parse(_year),
          'language': _language,
          'pages': int.parse(_numberOfPages),
          'type': _for,
          'description': _description,
        };

        // Add listing type specific data
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
        } // Call the book service to update the book
        final result = await BookService.updateBook(
          bookId: bookId,
          title: _title,
          author: _author,
          isbn: '', // Not required for now
          category: _category,
          price: bookData['price'] as double,
          condition: _condition,
          type: _for,
          pages: int.parse(_numberOfPages),
          year: int.parse(_year),
          language: _language,
          description: _description,
          rentalDays: bookData['rental_days'],
          exchangeCategory: bookData['exchange_category'],
        );

        // If book was updated successfully and user selected an image, upload it
        if (result['success'] == true && _image != null) {
          try {
            final imageResult = await BookService.uploadBookImage(
              bookId: bookId,
              imagePath: _image!.path,
            );

            if (imageResult['success'] != true) {
              print('Image upload failed: ${imageResult['message']}');
              // Don't show error to user since book was updated successfully
            }
          } catch (e) {
            print('Error uploading image: $e');
            // Don't show error to user since book was updated successfully
          }
        }

        if (result['success'] == true) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to update book'),
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
  } // Method to handle book deletion

  Future<void> _deleteBook() async {
    // Debug: Print the book ID and type
    print('=== Delete Book Debug Info ===');
    print('Book ID: "${widget.book.id}"');
    print('Book ID type: ${widget.book.id.runtimeType}');
    print('Book bookid getter: ${widget.book.bookid}');
    print('=============================');

    // Use the string ID directly - no need to convert to int
    final bookId = widget.book.id;

    if (bookId == null || bookId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Cannot delete this book: invalid book ID "${widget.book.id}"'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: Text(
              'Are you sure you want to delete "${widget.book.title}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await BookService.deleteBook(bookId);

      if (result['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(
            context, 'deleted'); // Return 'deleted' to indicate deletion
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete book'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
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
                              : widget.book.cover.startsWith('http')
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        widget.book.cover,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.add_photo_alternate,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Edit Book Cover',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Edit Book Cover',
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
                      initialValue: _title,
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
                    const SizedBox(height: 20), // Author Field
                    TextFormField(
                      initialValue: _author,
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
                      initialValue: _numberOfPages,
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
                      initialValue: _year,
                      decoration: const InputDecoration(
                        labelText: 'Publication Year',
                        hintText: 'Enter publication year',
                        border: OutlineInputBorder(),
                      ),
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
                      initialValue: _language,
                      decoration: const InputDecoration(
                        labelText: 'Language',
                        hintText: 'Enter book language',
                        border: OutlineInputBorder(),
                      ),
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
                    const SizedBox(height: 20),

                    // Description Field
                    TextFormField(
                      initialValue: _description,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter book description',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) {
                        _description = value ?? '';
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
                    const SizedBox(
                        height: 20), // Dynamic Fields based on Listing Type
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _for == 'Sell'
                          ? TextFormField(
                              key: const ValueKey('price'),
                              initialValue: _price.toString(),
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
                                  initialValue: _rentalDays.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Rental Period (Days)',
                                    hintText: 'Enter rental period in days',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  keyboardType: TextInputType.number,
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
                    const SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      children: [
                        // Delete Button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: _isLoading ? null : _deleteBook,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.delete, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete Book',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Update Button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onPressed: _isLoading ? null : _submitForm,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text(
                                    'Update Book',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
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
