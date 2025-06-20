import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get current user ID
import 'package:intl/intl.dart'; // For date and time formatting

class RequestFoodPage extends StatefulWidget { // Kept original class name for consistency with Admin.dart linkage
  const RequestFoodPage({Key? key}) : super(key: key);

  @override
  State<RequestFoodPage> createState() => _RequestFoodPageState();
}

class _RequestFoodPageState extends State<RequestFoodPage> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  // Text editing controllers for the form fields
  final TextEditingController _foodTypeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _requesterNameController = TextEditingController(); // Renamed
  final TextEditingController _requesterEmailController = TextEditingController(); // Renamed
  final TextEditingController _requesterPhoneController = TextEditingController(); // Renamed
  final TextEditingController _deliveryAddressController = TextEditingController(); // Renamed
  final TextEditingController _notesController = TextEditingController();

  // Variables for date and time pickers
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isSubmitting = false; // To show loading indicator

  @override
  void dispose() {
    // Dispose all controllers to free up resources
    _foodTypeController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _requesterNameController.dispose(); // Renamed
    _requesterEmailController.dispose(); // Renamed
    _requesterPhoneController.dispose(); // Renamed
    _deliveryAddressController.dispose(); // Renamed
    _notesController.dispose();
    super.dispose();
  }

  // Function to show a Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Cannot select past dates
      lastDate: DateTime(2028),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Function to show a Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Function to handle form submission
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a preferred delivery date and time.'), // Changed text
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final String userId = currentUser?.uid ?? 'anonymous_requester'; // Changed text
      final String requesterEmail = currentUser?.email ?? _requesterEmailController.text.trim(); // Renamed

      // Combine date and time into a single DateTime object
      final DateTime deliveryDateTime = DateTime( // Renamed
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection('Foodrequests').add({
        'userId': userId,
        'foodType': _foodTypeController.text.trim(),
        'quantity': double.tryParse(_quantityController.text.trim()) ?? 0.0,
        'unit': _unitController.text.trim(),
        'requesterName': _requesterNameController.text.trim(), // Renamed
        'requesterEmail': requesterEmail, // Renamed
        'requesterPhone': _requesterPhoneController.text.trim(), // Renamed
        'deliveryAddress': _deliveryAddressController.text.trim(), // Renamed
        'deliveryDateTime': deliveryDateTime.toIso8601String(), // Renamed
        'notes': _notesController.text.trim(),
        'status': 'Pending', // Initial status
        'submittedAt': FieldValue.serverTimestamp(), // Timestamp of submission
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food request submitted successfully!'), // Changed text
          backgroundColor: Colors.green,
        ),
      );

      // Clear form fields
      _formKey.currentState!.reset();
      _foodTypeController.clear();
      _quantityController.clear();
      _unitController.clear();
      _requesterNameController.clear(); // Renamed
      _requesterEmailController.clear(); // Renamed
      _requesterPhoneController.clear(); // Renamed
      _deliveryAddressController.clear(); // Renamed
      _notesController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
      });

    } catch (e) {
      print('Error submitting food request: $e'); // Changed text
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Food', // Changed title
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell us about your food needs:', // Changed text
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),

              // Food Type
              TextFormField(
                controller: _foodTypeController,
                decoration: _inputDecoration('Type of Food (e.g., Cooked meals, Fruits, Vegetables)'), // Changed text
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter food type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Quantity and Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Quantity Needed (e.g., 5, 2.5)'), // Changed text
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter a number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _unitController,
                      decoration: _inputDecoration('Unit (e.g., kg, meals, dozens)'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Your Contact Information:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 15),

              // Requester Name
              TextFormField(
                controller: _requesterNameController, // Renamed
                decoration: _inputDecoration('Your Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Requester Email
              TextFormField(
                controller: _requesterEmailController, // Renamed
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('Your Email Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Requester Phone
              TextFormField(
                controller: _requesterPhoneController, // Renamed
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('Your Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'Delivery Details:', // Changed text
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 15),

              // Delivery Address
              TextFormField(
                controller: _deliveryAddressController, // Renamed
                maxLines: 3,
                decoration: _inputDecoration('Delivery Address'), // Changed text
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter delivery address'; // Changed text
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Date and Time Pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: _inputDecoration('Preferred Delivery Date').copyWith( // Changed text
                          prefixIcon: const Icon(Icons.calendar_today),
                          errorText: _selectedDate == null && _formKey.currentState?.validate() == false
                              ? 'Date required' : null,
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : DateFormat('MMM dd, YYYY').format(_selectedDate!),
                          style: TextStyle(
                            color: _selectedDate == null ? Colors.grey[700] : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: _inputDecoration('Preferred Delivery Time').copyWith( // Changed text
                          prefixIcon: const Icon(Icons.access_time),
                          errorText: _selectedTime == null && _formKey.currentState?.validate() == false
                              ? 'Time required' : null,
                        ),
                        child: Text(
                          _selectedTime == null
                              ? 'Select Time'
                              : _selectedTime!.format(context),
                          style: TextStyle(
                            color: _selectedTime == null ? Colors.grey[700] : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Additional Notes
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: _inputDecoration('Additional Notes (e.g., allergies, special delivery instructions)'), // Changed text
              ),
              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Submit Food Request', // Changed text
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function for consistent InputDecoration styling
  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
    );
  }
}