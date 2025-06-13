import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String? _foodType;
  String? _quantity;
  String? _unit = 'Kg';
  DateTime? _pickupDateTime;
  String? _address;
  String? _instructions;

  final List<String> _foodTypes = ['Cooked', 'Packaged', 'Dry'];
  final List<String> _units = ['Kg', 'Liters', 'Boxes'];

  final List<Map<String, String>> _donationHistory = [];

  bool _isHovered = false;

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

  void _submitDonation() {
    if (!_formKey.currentState!.validate() || _pickupDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete the form properly.")),
      );
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _donationHistory.add({
        'food': "${_foodType ?? ''} (${_quantity ?? ''} $_unit)",
        'date': DateFormat('MMM dd, yyyy – hh:mm a').format(_pickupDateTime!),
        'status': 'Pending',
      });
    });

    // Reset form
    _formKey.currentState!.reset();
    _foodType = null;
    _quantity = null;
    _unit = 'Kg';
    _pickupDateTime = null;
    _address = null;
    _instructions = null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Donation submitted successfully!")),
    );
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
              MaterialPageRoute(builder: (_) =>  const HomeScreen()),
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

          }
          else if (index == 2) {
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
        actions: [
          Icon(Icons.location_on_outlined),
          SizedBox(width: 10),
          Center(child: Text("Current Location")),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📝 Donation Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Food Type",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _foodType,
                    decoration:
                    InputDecoration(border: OutlineInputBorder()),
                    items: _foodTypes
                        .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (val) => setState(() => _foodType = val),
                    validator: (val) =>
                    val == null ? 'Please select a food type' : null,
                  ),
                  SizedBox(height: 12),

                  Text("Quantity",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                              hintText: "Enter quantity",
                              border: OutlineInputBorder()),
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
                            .map((u) =>
                            DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  Text("Pickup Date & Time",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: _selectDateTime,
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _pickupDateTime == null
                            ? "Select Date & Time"
                            : DateFormat('MMM dd, yyyy – hh:mm a')
                            .format(_pickupDateTime!),
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

                  Text("Address",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    decoration: InputDecoration(
                        hintText: "Enter your address",
                        border: OutlineInputBorder()),
                    onSaved: (val) => _address = val,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                          return 'Address is required';
                      }
                      if (!RegExp(r'^[\w\s,.-]{10,}$').hasMatch(val.trim())) {
                        return 'Enter a valid address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),

                  Text("Special Instructions (optional)",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    maxLines: 3,
                    decoration: InputDecoration(
                        hintText: "Any notes",
                        border: OutlineInputBorder()),
                    onSaved: (val) => _instructions = val,
                  ),
                  SizedBox(height: 20),

                  // Hover effect on the submit button
                  Center(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isHovered = true),
                      onExit: (_) => setState(() => _isHovered = false),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isHovered
                              ? Colors.deepPurple[700]
                              : Colors.deepPurple,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                        ),
                        onPressed: _submitDonation,
                        child: Text("Submit Donation",
                            style: TextStyle(color: Colors.white)),
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

            if (_donationHistory.isEmpty)
              Text("No donations yet.", style: TextStyle(color: Colors.grey)),
            ..._donationHistory.map((item) {
              return Card(
                child: ListTile(
                  title: Text(item['food']!),
                  subtitle: Text(item['date']!),
                  trailing: Text(
                    item['status']!,
                    style: TextStyle(
                      color: item['status'] == 'Delivered'
                          ? Colors.green
                          : item['status'] == 'Picked'
                          ? Colors.orange
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
