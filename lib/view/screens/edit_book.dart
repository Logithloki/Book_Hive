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
    'Biography'
  ];

  // Conditions for the book
  final List<String> _conditions = ['New', 'Good', 'Fair', 'Poor'];

  @override
  void initState() {
    super.initState();
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
        // Convert book ID to int from the original string ID
        final bookId = int.tryParse(widget.book.id ?? '0') ?? 0;
        if (bookId <= 0) {
          throw Exception('Invalid book ID');
        }

        // Call the book service to update the book
        final result = await BookService.updateBook(
          bookId: bookId,
          title: _title,
          author: _author,
          isbn: '', // Not required for now
          category: _category,
          price: _price,
          condition: _condition,
          description: _description,
          // Add additional fields as needed
        );

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
                    const SizedBox(height: 20),

                    // Author Field
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
                    const SizedBox(height: 20),

                    // Listing Type (Sell, Exchange, Rent)
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
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                elevation: _for == 'Sell' ? 4 : 1,
                                color: _for == 'Sell'
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : null,
                                child: RadioListTile<String>(
                                  title: Column(
                                    children: [
                                      Icon(
                                        Icons.sell,
                                        size: 32,
                                        color: _for == 'Sell'
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : null,
                                      ),
                                      const Text('Sell'),
                                    ],
                                  ),
                                  value: 'Sell',
                                  groupValue: _for,
                                  onChanged: (value) {
                                    setState(() {
                                      _for = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                elevation: _for == 'Rent' ? 4 : 1,
                                color: _for == 'Rent'
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : null,
                                child: RadioListTile<String>(
                                  title: Column(
                                    children: [
                                      Icon(
                                        Icons.book,
                                        size: 32,
                                        color: _for == 'Rent'
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : null,
                                      ),
                                      const Text('Rent'),
                                    ],
                                  ),
                                  value: 'Rent',
                                  groupValue: _for,
                                  onChanged: (value) {
                                    setState(() {
                                      _for = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                elevation: _for == 'Exchange' ? 4 : 1,
                                color: _for == 'Exchange'
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : null,
                                child: RadioListTile<String>(
                                  title: Column(
                                    children: [
                                      Icon(
                                        Icons.swap_horiz,
                                        size: 32,
                                        color: _for == 'Exchange'
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : null,
                                      ),
                                      const Text('Exchange'),
                                    ],
                                  ),
                                  value: 'Exchange',
                                  groupValue: _for,
                                  onChanged: (value) {
                                    setState(() {
                                      _for = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
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
                                'Update Book',
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
