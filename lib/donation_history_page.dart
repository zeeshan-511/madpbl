import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationHistoryPage extends StatefulWidget {
  @override
  _DonationHistoryPageState createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
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
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Picked':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Delivered':
        return Icons.check_circle;
      case 'Picked':
        return Icons.local_shipping;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation History'),
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
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

            var docs = snapshot.data!.docs;
            docs.sort((a, b) {
              dynamic aData = a.data();
              dynamic bData = b.data();
              DateTime? aDate = _parseTimestamp(aData['submittedAt']);
              DateTime? bDate = _parseTimestamp(bData['submittedAt']);
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
                              "${data['foodType']} - ${data['quantity']} ${data['unit']}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(_getStatusIcon(data['status']),
                                    color: _getStatusColor(data['status']), size: 18),
                                SizedBox(width: 6),
                                Text(
                                  data['status'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(data['status']),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Pickup Time
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              "Pickup: ${_formatDate(data['pickupDateTime'])}",
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Address
                        if (data['address'] != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  data['address'],
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                              ),
                            ],
                          ),

                        // Contact (Optional to show)
                        if (data['contactNo'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.phone, size: 18, color: Colors.grey[600]),
                                SizedBox(width: 6),
                                Text(data['contactNo']),
                              ],
                            ),
                          ),

                        // Instructions
                        if (data['instructions'] != null &&
                            (data['instructions'] as String).trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    data['instructions'],
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
