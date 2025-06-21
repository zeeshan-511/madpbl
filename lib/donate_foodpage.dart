import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'CustomBottomNav.dart';
import 'donation_page.dart';
import 'account_page.dart';
import 'home_screen.dart';
import 'notification.dart';

class DonateFoodPage extends StatefulWidget {
  @override
  _DonateFoodPageState createState() => _DonateFoodPageState();
}

class _DonateFoodPageState extends State<DonateFoodPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _foodType;
  String? _quantity;
  String? _unit = 'Kg';
  DateTime? _pickupDateTime;
  String? _address;
  String? _instructions;
  String? _contactNo;

  final List<String> _foodTypes = ['Cooked', 'Packaged', 'Dry'];
  final List<String> _units = ['Kg', 'Liters', 'Boxes'];

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();

  bool _isHovered = false;

  @override
  void dispose() {
    _addressController.dispose();
    _contactNoController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 12, minute: 0),
      );

      if (time != null) {
        setState(() {
          _pickupDateTime = DateTime(
              date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, cannot request.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> _getAddressFromLatLng(Position position) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}';

    final response = await http.get(Uri.parse(url), headers: {
      'User-Agent': 'FlutterApp'
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['display_name'] ?? 'No address found';
    } else {
      throw Exception('Failed to fetch address');
    }
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate() || _pickupDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete the form properly.")),
      );
      return;
    }

    _formKey.currentState!.save();

    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to donate")),
      );
      return;
    }

    final donationData = {
      'foodType': _foodType,
      'quantity': _quantity,
      'unit': _unit,
      'pickupDateTime': _pickupDateTime!.toIso8601String(),
      'address': _address,
      'instructions': _instructions,
      'contactNo': _contactNo,
      'status': 'Pending',
      'submittedAt': FieldValue.serverTimestamp(),
      'userId': user.uid,
    };

    try {
      DocumentReference docRef = await _firestore.collection('donations').add(donationData);
      debugPrint('Donation submitted with ID: ${docRef.id}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Donation submitted successfully!")),
      );
    } catch (e) {
      debugPrint('Error submitting donation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save donation: $e")),
      );
    }

    _formKey.currentState!.reset();
    setState(() {
      _foodType = null;
      _quantity = null;
      _unit = 'Kg';
      _pickupDateTime = null;
      _instructions = null;
      _contactNo = null;
    });
    _addressController.clear();
    _contactNoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DonationsScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AccountPage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => Notificationpage()),
            );
          }
        },
      ),
      appBar: AppBar(
        title: Text("Donate Food"),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Food Type", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _foodType,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    items: _foodTypes
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (val) => setState(() => _foodType = val),
                    validator: (val) => val == null ? 'Please select a food type' : null,
                  ),
                  SizedBox(height: 12),

                  Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                              hintText: "Enter quantity", border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          onSaved: (val) => _quantity = val,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Quantity is required";
                            }
                            if (!RegExp(r'^\d+$').hasMatch(val.trim())) {
                              return "Enter a valid number";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _unit,
                        onChanged: (val) => setState(() => _unit = val),
                        items: _units
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  Text("Contact Number", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _contactNoController,
                    decoration: InputDecoration(
                      hintText: "Enter your phone number",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    onSaved: (val) => _contactNo = val,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Contact number is required';
                      }
                      if (!RegExp(r'^[0-9]{10,}$').hasMatch(val.trim())) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),

                  Text("Pickup Date & Time", style: TextStyle(fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: _selectDateTime,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _pickupDateTime == null
                            ? "Select Date & Time"
                            : DateFormat('MMM dd, yyyy – hh:mm a').format(_pickupDateTime!),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  if (_pickupDateTime == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Pickup date & time is required',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  SizedBox(height: 12),

                  Text("Address", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                              hintText: "Enter your address", border: OutlineInputBorder()),
                          onSaved: (val) => _address = val,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Address is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.my_location),
                        onPressed: () async {
                          try {
                            final position = await _determinePosition();
                            final address = await _getAddressFromLatLng(position);
                            setState(() {
                              _addressController.text = address;
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 12),

                  Text("Special Instructions (optional)",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    maxLines: 3,
                    decoration: InputDecoration(hintText: "Any notes", border: OutlineInputBorder()),
                    onSaved: (val) => _instructions = val,
                  ),
                  SizedBox(height: 20),

                  Center(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isHovered = true),
                      onExit: (_) => setState(() => _isHovered = false),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isHovered
                              ? Colors.deepPurple[700]
                              : Colors.deepPurple,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        ),
                        onPressed: _submitDonation,
                        child: Text("Submit Donation", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const Text("Donation History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // MODIFIED STREAMBUILDER - WORKING VERSION
            StreamBuilder<QuerySnapshot>(
    stream: _auth.currentUser != null
    ? _firestore
        .collection('donations')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .snapshots()
        : null,
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
    return Text('Error loading donations: ${snapshot.error}');
    }

    if (_auth.currentUser == null) {
    return Text("Please log in to view your donation history",
    style: TextStyle(color: Colors.grey));
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return Text("No donations yet.", style: TextStyle(color: Colors.grey));
    }

    // Sort documents locally by submittedAt with proper type handling
    var docs = snapshot.data!.docs;
    docs.sort((a, b) {
    dynamic aData = a.data();
    dynamic bData = b.data();

    DateTime? aDate = _parseTimestamp(aData['submittedAt']);
    DateTime? bDate = _parseTimestamp(bData['submittedAt']);

    return bDate?.compareTo(aDate ?? DateTime.now()) ?? 0;
    });

    return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: docs.length,
    itemBuilder: (context, index) {
    var doc = docs[index];
    var data = doc.data() as Map<String, dynamic>;

    return Card(
    margin: EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
    title: Text("${data['foodType']} (${data['quantity']} ${data['unit']})"),
    subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text("Pickup: ${_formatDate(data['pickupDateTime'])}"),
    if (data['address'] != null)
    Text("Address: ${data['address']}",
    overflow: TextOverflow.ellipsis),
    Text("Status: ${data['status']}",
    style: TextStyle(
    color: _getStatusColor(data['status']),
    )),
    ],
    ),
    trailing: Icon(Icons.arrow_forward_ios, size: 16),                // Add navigation to donation details if needed
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.tryParse(timestamp);
    return null;
  }

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        return DateFormat('MMM dd, yyyy – hh:mm a').format(DateTime.parse(date));
      } else if (date is Timestamp) {
        return DateFormat('MMM dd, yyyy – hh:mm a').format(date.toDate());
      }
      return 'Invalid date';
    } catch (e) {
      return 'Date format error';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Picked':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}