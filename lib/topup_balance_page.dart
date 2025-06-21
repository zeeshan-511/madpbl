import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TopUpBalancePage extends StatefulWidget {
  @override
  _TopUpBalancePageState createState() => _TopUpBalancePageState();
}

class _TopUpBalancePageState extends State<TopUpBalancePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _isLoading = false;
  String? _statusMessage;

  Future<void> _simulatePaymentAndTopUp() async {
    if (!_formKey.currentState!.validate()) return;

    final double amount = double.parse(_amountController.text.trim());
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => _statusMessage = "User not logged in.");
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await Future.delayed(Duration(seconds: 2)); // Simulate payment delay

      await FirebaseFirestore.instance.collection('topups').add({
        'email': user.email,
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isLoading = false;
        _statusMessage =
        "Top-up Successful! \$${amount.toStringAsFixed(2)} added.";
      });

      _cardNumberController.clear();
      _expiryDateController.clear();
      _cvvController.clear();
      _amountController.clear();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Error: ${e.toString()}";
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      border: OutlineInputBorder(),
      labelText: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Top Up Balance")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Enter Payment Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),

              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Card Number"),
                maxLength: 16,
                validator: (value) {
                  if (value == null || value.length != 16) {
                    return "Enter a valid 16-digit card number";
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      keyboardType: TextInputType.datetime,
                      decoration: _inputDecoration("MM/YY"),
                      validator: (value) {
                        if (value == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                          return "Invalid expiry";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("CVV"),
                      maxLength: 3,
                      validator: (value) {
                        if (value == null || value.length != 3) {
                          return "Invalid CVV";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration("Amount"),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                    return "Enter valid amount";
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: _simulatePaymentAndTopUp,
                icon: Icon(Icons.payment),
                label: Text("Top Up"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),

              SizedBox(height: 20),

              if (_statusMessage != null)
                Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.startsWith("Top-up") ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
