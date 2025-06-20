// contact_messages_page.dart (or directly in your admin_panel.dart file)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactMessagesPage extends StatefulWidget {
  const ContactMessagesPage({Key? key}) : super(key: key);

  @override
  State<ContactMessagesPage> createState() => _ContactMessagesPageState();
}

class _ContactMessagesPageState extends State<ContactMessagesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controller for the reply text field
  final TextEditingController _replyController = TextEditingController();

  void _showReplyDialog(BuildContext context, DocumentSnapshot message) {
    _replyController.text = (message.data() as Map<String, dynamic>).containsKey('adminReply')
        ? message['adminReply'] ?? ''
        : ''; // Safely pre-fill if 'adminReply' exists // Pre-fill if there's an existing reply

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(
            maxHeight: 500,
            maxWidth: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.reply, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reply to ${message['name'] ?? 'User'}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Message Details
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From: ${message['name'] ?? 'N/A'} (${message['email'] ?? 'N/A'})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Message:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        message['message'] ?? 'No message content.',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      // Reply Input
                      TextField(
                        controller: _replyController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Your Reply',
                          hintText: 'Type your response here...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => _sendReply(context, message.id, _replyController.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Send Reply', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendReply(BuildContext context, String messageId, String replyText) async {
    try {
      await _firestore.collection('contactMessages').doc(messageId).update({
        'adminReply': replyText.trim(),
        'isRead': true, // Mark as read when replied
        'repliedAt': FieldValue.serverTimestamp(), // Add a timestamp for the reply
      });
      Navigator.pop(context); // Close the dialog
      _showSnackBar(context, 'Reply sent successfully!', Colors.green);
    } catch (e) {
      _showSnackBar(context, 'Error sending reply: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _toggleReadStatus(String messageId, bool currentStatus) async {
    try {
      await _firestore.collection('contactMessages').doc(messageId).update({
        'isRead': !currentStatus,
      });
      _showSnackBar(context, 'Message status updated!', Colors.blue);
    } catch (e) {
      _showSnackBar(context, 'Error updating status: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('contactMessages').doc(messageId).delete();
                Navigator.pop(context);
                _showSnackBar(context, 'Message deleted successfully!', Colors.green);
              } catch (e) {
                Navigator.pop(context);
                _showSnackBar(context, 'Error deleting message: ${e.toString()}', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contact Messages',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('contactMessages').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mail_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No contact messages found.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final message = snapshot.data!.docs[index];
                    final messageData = message.data() as Map<String, dynamic>;
                    final bool isRead = messageData['isRead'] ?? false;
                    final Timestamp? timestamp = messageData['timestamp'] as Timestamp?;
                    final String formattedDate = timestamp != null
                        ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year} ${timestamp.toDate().hour}:${timestamp.toDate().minute}'
                        : 'N/A';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: isRead ? Colors.white : Colors.blue.shade50, // Highlight unread messages
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'From: ${messageData['name'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: isRead ? Colors.black87 : Colors.deepPurple,
                                    ),
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Email: ${messageData['email'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              messageData['message'] ?? 'No message content.',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            if (messageData['adminReply'] != null && messageData['adminReply'].isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  const SizedBox(height: 5),
                                  const Text(
                                    'Admin Reply:',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                  ),
                                  Text(
                                    messageData['adminReply'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _toggleReadStatus(message.id, isRead),
                                  icon: Icon(
                                    isRead ? Icons.mark_email_unread : Icons.mark_email_read,
                                    color: isRead ? Colors.orange : Colors.green,
                                  ),
                                  label: Text(isRead ? 'Mark Unread' : 'Mark Read'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _showReplyDialog(context, message),
                                  icon: const Icon(Icons.reply, color: Colors.white),
                                  label: const Text('Reply', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteMessage(message.id),
                                ),
                              ],
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
        ],
      ),
    );
  }
}