import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class TransferHistoryPage extends StatefulWidget {
  @override
  _TransferHistoryPageState createState() => _TransferHistoryPageState();
}

class _TransferHistoryPageState extends State<TransferHistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'paid':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'paid':
        return Icons.payment;
      case 'failed':
        return Icons.error;
      default:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer History'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: _auth.currentUser != null
              ? _firestore
              .collection('transfers')
              .where('email', isEqualTo: _auth.currentUser!.email)
              .snapshots()
              : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Error loading transfers: ${snapshot.error}');
            }

            if (_auth.currentUser == null) {
              return Text("Please log in to view your transfer history",
                  style: TextStyle(color: Colors.grey));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Text("No transfers yet.", style: TextStyle(color: Colors.grey));
            }

            var docs = snapshot.data!.docs;
            docs.sort((a, b) {
              dynamic aData = a.data();
              dynamic bData = b.data();
              DateTime? aDate = _parseTimestamp(aData['timestamp']);
              DateTime? bDate = _parseTimestamp(bData['timestamp']);
              return bDate?.compareTo(aDate ?? DateTime.now()) ?? 0;
            });

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var doc = docs[index];
                var data = doc.data() as Map<String, dynamic>;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "\$${data['amount']?.toStringAsFixed(2) ?? '0.00'}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(_getStatusIcon(data['status'] ?? 'paid'),
                                    color: _getStatusColor(data['status'] ?? 'paid'),
                                    size: 18),
                                SizedBox(width: 6),
                                Text(
                                  data['status']?.toString().toUpperCase() ?? 'PAID',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(data['status'] ?? 'paid'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Campaign Info
                        Row(
                          children: [
                            Icon(Icons.campaign, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "${data['campaignTitle'] ?? 'No campaign'} - ${data['campaignSubtitle'] ?? ''}",
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Donor Name
                        Row(
                          children: [
                            Icon(Icons.person, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              "Donor: ${data['donorName'] ?? 'Anonymous'}",
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Transfer Date
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              "Date: ${_formatDate(data['timestamp'])}",
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Message (Optional)
                        if (data['message'] != null && data['message'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.message, size: 18, color: Colors.grey[600]),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    data['message'],
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}