import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:madpbl/contact_messages_page.dart';
import 'package:madpbl/volunteer_sessions_page.dart';

class AdminPanelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlatePromise Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: AdminHomeScreen(),
    );
  }
}

// ... (your existing imports and main function)

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String _title = 'Dashboard';
  Widget _selectedWidget = DashboardPage();

  void _selectPage(String title, Widget page) {
    setState(() {
      _title = title;
      _selectedWidget = page;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text('Admin Panel', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', DashboardPage()),
            _buildDrawerItem(Icons.person, 'Users Food Requests', UsersPage()),
            _buildDrawerItem(Icons.fastfood, 'Donations', DonationsPage()),
            _buildDrawerItem(Icons.list_alt, 'Requests', RequestsPage()),


            // --- CHANGE THIS LINE ---
            _buildDrawerItem(Icons.mail, 'Contact Messages',  ContactMessagesPage()),
           _buildDrawerItem(Icons.volunteer_activism, 'Volunteer Sessions', VolunteerSessionsPage()),

            // Changed icon and page
            // _buildDrawerItem(Icons.pie_chart, 'Reports', ReportsPage()), // You can keep ReportsPage if you still need it for other reports
            _buildDrawerItem(Icons.notifications, 'Notifications', NotificationsPage()),


            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: _selectedWidget,
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => _selectPage(title, page),
    );
  }
}

// ... (Rest of your existing classes: DashboardPage, UsersPage, DonationsPage, RequestsPage, AgentsPage, ReportsPage, NotificationsPage, RewardsPage, SettingsPage)

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Welcome to PlatePromise Admin Dashboard'));
  }
}

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _firestore.collection('Foodrequests').doc(requestId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request status updated to $newStatus'),
          backgroundColor: Colors.green, // Provide visual feedback
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: ${e.toString()}'),
          backgroundColor: Colors.red, // Provide visual feedback
        ),
      );
    }
  }

  // NEW: Method to delete a request
  Future<void> _deleteRequest(String requestId) async {
    // Show a confirmation dialog before deleting
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request'),
        content: const Text('Are you sure you want to delete this food request? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // User canceled
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // User confirmed
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('Foodrequests').doc(requestId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food request deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Denied':
        return Colors.red;
      case 'Picked Up': // Assuming a "Picked Up" status for food requests
        return Colors.orange;
      case 'Delivered':
        return Colors.blue;
      case 'Pending': // Added Pending for completeness
        return Colors.grey;
      default:
        return Colors.purple; // For any unrecognised status
    }
  }

  Widget _buildStatusDropdown(String currentStatus, String requestId) {
    return Container( // Wrap dropdown in Container for styling
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _getStatusColor(currentStatus).withOpacity(0.1), // Light background based on status
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(currentStatus)),
      ),
      child: DropdownButtonHideUnderline( // Hides the default underline
        child: DropdownButton<String>(
          value: currentStatus,
          icon: Icon(Icons.arrow_drop_down, color: _getStatusColor(currentStatus)),
          elevation: 8, // Less elevation for a cleaner look
          style: TextStyle(color: _getStatusColor(currentStatus), fontWeight: FontWeight.bold),
          onChanged: (String? newValue) {
            if (newValue != null) {
              _updateRequestStatus(requestId, newValue);
            }
          },
          items: <String>['Pending', 'Approved', 'Denied', 'Picked Up', 'Delivered'] // Define your statuses
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Food Requests'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0, // Removed elevation for a flat look
        centerTitle: true, // Center the title
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Foodrequests').orderBy('submittedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fastfood, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No food requests found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final request = snapshot.data!.docs[index];
              final data = request.data() as Map<String, dynamic>;

              DateTime? deliveryDateTime;
              try {
                if (data['deliveryDateTime'] is String) {
                  deliveryDateTime = DateTime.parse(data['deliveryDateTime']);
                } else if (data['deliveryDateTime'] is Timestamp) {
                  deliveryDateTime = (data['deliveryDateTime'] as Timestamp).toDate();
                }
              } catch (e) {

                print('Error parsing pickupDateTime for request ${request.id}: ${data['pickupDateTime']} - $e');
                deliveryDateTime = null;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${data['foodType'] ?? 'N/A'} (${data['quantity'] ?? 'N/A'} ${data['unit'] ?? 'N/A'})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // NEW: PopupMenuButton for actions (e.g., Delete)
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteRequest(request.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete Request'),
                                  ],
                                ),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                          ),
                        ],
                      ),
                      const Divider(height: 16, thickness: 1),
                      _buildInfoRow(Icons.person, 'Requester Name', data['requesterName']),
                      _buildInfoRow(Icons.email, 'Requester Email', data['requesterEmail']),
                      _buildInfoRow(Icons.phone, 'Requester Phone', data['RequesterPhone']),
                      _buildInfoRow(Icons.location_on, 'Deliever Address', data['deliveryAddress']),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Delievery Date/Time',
                        deliveryDateTime != null
                            ? DateFormat('MMM dd, yyyy - hh:mm a').format(deliveryDateTime) // Added year for clarity
                            : 'Not specified',
                      ),
                      if (data['notes'] != null && data['notes'].isNotEmpty)
                        _buildInfoRow(Icons.notes, 'Notes', data['notes']),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildStatusDropdown(data['status'] ?? 'Pending', request.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                Text(
                  value ?? 'N/A', // Display 'N/A' if value is null
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DonationsPage extends StatefulWidget {
  @override
  _DonationsPageState createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showAddCampaignDialog() {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final imageUrlController = TextEditingController();
    final amountController = TextEditingController();
    final daysLeftController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.campaign, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add New Campaign',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildAnimatedTextField(titleController, 'Campaign Title', Icons.title),
                      SizedBox(height: 16),
                      _buildAnimatedTextField(subtitleController, 'Campaign Description', Icons.description, maxLines: 3),
                      SizedBox(height: 16),
                      _buildAnimatedTextField(imageUrlController, 'Image URL', Icons.image),
                      SizedBox(height: 16),
                      _buildAnimatedTextField(amountController, 'Target Amount (\$)', Icons.monetization_on, isNumber: true),
                      SizedBox(height: 16),
                      _buildAnimatedTextField(daysLeftController, 'Days Left (e.g., "30 days to go")', Icons.timer),
                      SizedBox(height: 24),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => _addCampaign(titleController, subtitleController, imageUrlController, amountController, daysLeftController),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text('Add Campaign', style: TextStyle(color: Colors.white)),
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

  void _showEditCampaignDialog(DocumentSnapshot campaign) {
    final titleController = TextEditingController(text: campaign['title']);
    final subtitleController = TextEditingController(text: campaign['subtitle']);
    final imageUrlController = TextEditingController(text: campaign['imageUrl']);
    final amountController = TextEditingController(text: campaign['amount']?.toString() ?? '0');
    final daysLeftController = TextEditingController(text: campaign['daysLeft'] ?? '30 days to go');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Edit Campaign',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildAnimatedTextField(titleController, 'Campaign Title', Icons.title),
                      SizedBox(height: 16),
                      _buildAnimatedTextField(subtitleController, 'Campaign Description', Icons.description, maxLines: 3),
                      SizedBox(height: 16),
                      _buildAnimatedTextField(imageUrlController, 'Image URL', Icons.image),
                      SizedBox(height: 16),
                      _buildAnimatedTextField(amountController, 'Target Amount (\$)', Icons.monetization_on, isNumber: true),
                      SizedBox(height: 16),
                      _buildAnimatedTextField(daysLeftController, 'Days Left (e.g., "30 days to go")', Icons.timer),
                      SizedBox(height: 24),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => _updateCampaign(campaign.id, titleController, subtitleController, imageUrlController, amountController, daysLeftController),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text('Update Campaign', style: TextStyle(color: Colors.white)),
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

  Widget _buildAnimatedTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool isNumber = false}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: Opacity(
          opacity: value,
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: Colors.deepPurple),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.deepPurple, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addCampaign(TextEditingController titleController, TextEditingController subtitleController,
      TextEditingController imageUrlController, TextEditingController amountController, TextEditingController daysLeftController) async {
    if (titleController.text.isNotEmpty && subtitleController.text.isNotEmpty) {
      try {
        await _firestore.collection('Donation').add({
          'title': titleController.text.trim(),
          'subtitle': subtitleController.text.trim(),
          'imageUrl': imageUrlController.text.trim(),
          'amount': double.tryParse(amountController.text) ?? 0.0,
          'daysLeft': daysLeftController.text.isEmpty ? '30 days to go' : daysLeftController.text.trim(),
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        Navigator.pop(context);
        _showSnackBar('Campaign added successfully!', Colors.green);
      } catch (e) {
        _showSnackBar('Error adding campaign: ${e.toString()}', Colors.red);
      }
    } else {
      _showSnackBar('Please fill in required fields', Colors.orange);
    }
  }

  void _updateCampaign(String campaignId, TextEditingController titleController, TextEditingController subtitleController,
      TextEditingController imageUrlController, TextEditingController amountController, TextEditingController daysLeftController) async {
    if (titleController.text.isNotEmpty && subtitleController.text.isNotEmpty) {
      try {
        await _firestore.collection('Donation').doc(campaignId).update({
          'title': titleController.text.trim(),
          'subtitle': subtitleController.text.trim(),
          'imageUrl': imageUrlController.text.trim(),
          'amount': double.tryParse(amountController.text) ?? 0.0,
          'daysLeft': daysLeftController.text.isEmpty ? '30 days to go' : daysLeftController.text.trim(),
        });
        Navigator.pop(context);
        _showSnackBar('Campaign updated successfully!', Colors.green);
      } catch (e) {
        _showSnackBar('Error updating campaign: ${e.toString()}', Colors.red);
      }
    } else {
      _showSnackBar('Please fill in required fields', Colors.orange);
    }
  }

  void _deleteCampaign(String campaignId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Campaign'),
        content: Text('Are you sure you want to delete this campaign? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('Donation').doc(campaignId).delete();
                Navigator.pop(context);
                _showSnackBar('Campaign deleted successfully!', Colors.green);
              } catch (e) {
                Navigator.pop(context);
                _showSnackBar('Error deleting campaign: ${e.toString()}', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Food Donations ',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddCampaignDialog,
                      icon: Icon(Icons.add, color: Colors.deepPurple),
                      label: Text('Add Campaign', style: TextStyle(color: Colors.deepPurple)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('Donation').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.campaign, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No campaigns found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final campaign = snapshot.data!.docs[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 600 + (index * 100)),
                          builder: (context, value, child) => Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: Card(
                                margin: EdgeInsets.only(bottom: 16),
                                elevation: 8,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [Colors.white, Colors.grey.shade50],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(16),
                                    leading: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                                        image: campaign['imageUrl'].isNotEmpty ? DecorationImage(
                                          image: NetworkImage(campaign['imageUrl']),
                                          fit: BoxFit.cover,
                                          onError: (error, stackTrace) {},
                                        ) : null,
                                      ),
                                      child: campaign['imageUrl'].isEmpty ? Icon(Icons.image, color: Colors.grey) : null,
                                    ),
                                    title: Text(campaign['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 4),
                                        Text(campaign['subtitle'], maxLines: 2, overflow: TextOverflow.ellipsis),
                                        SizedBox(height: 4),
                                        Text('\$${(campaign['amount'] ?? 0.0).toStringAsFixed(0)}',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                                        Text(campaign['daysLeft'] ?? '30 days to go',
                                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                                        SizedBox(height: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: campaign['isActive'] ? Colors.green : Colors.red,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            campaign['isActive'] ? 'Active' : 'Inactive',
                                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditCampaignDialog(campaign);
                                        } else if (value == 'delete') {
                                          _deleteCampaign(campaign.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, color: Colors.blue),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      icon: Icon(Icons.more_vert, color: Colors.deepPurple),
                                    ),
                                  ),
                                ),
                              ),
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
        ),
      ),
    );
  }
}

class RequestsPage extends StatefulWidget {
  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateDonationStatus(String donationId, String newStatus) async {
    try {
      await _firestore.collection('donations').doc(donationId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: ${e.toString()}')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Denied':
        return Colors.red;
      case 'Picked':
        return Colors.orange;
      case 'Delivered':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusDropdown(String currentStatus, String donationId) {
    return DropdownButton<String>(
      value: currentStatus,
      icon: Icon(Icons.arrow_drop_down),
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(height: 2, color: Colors.deepPurple),
      onChanged: (String? newValue) {
        if (newValue != null) {
          _updateDonationStatus(donationId, newValue);
        }
      },
      items: <String>['Pending', 'Approved', 'Denied', 'Picked', 'Delivered']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('donations').orderBy('submittedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading donations'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No donation requests found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final donation = snapshot.data!.docs[index];
              final data = donation.data() as Map<String, dynamic>;

              // Parse the date safely
              DateTime? pickupDate;
              try {
                pickupDate = DateTime.parse(data['pickupDateTime']);
              } catch (e) {
                pickupDate = null;
              }

              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${data['foodType']} (${data['quantity']} ${data['unit']})',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(data['status']).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(data['status']),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              data['status'],
                              style: TextStyle(
                                color: _getStatusColor(data['status']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Pickup: ${pickupDate != null ? DateFormat('MMM dd, yyyy - hh:mm a').format(pickupDate) : 'Date not available'}'),
                      SizedBox(height: 4),
                      Text('Address: ${data['address'] ?? 'Not provided'}'),
                      SizedBox(height: 4),
                      if (data['instructions'] != null && data['instructions'].isNotEmpty)
                        Text('Instructions: ${data['instructions']}'),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Contact: ${data['contactNo'] ?? 'Not provided'}'),
                          _buildStatusDropdown(data['status'], donation.id),
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
    );
  }
}




class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Send and Manage App Notifications'));
  }
}