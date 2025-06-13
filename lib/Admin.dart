import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(AdminPanelApp());
}


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
    Navigator.pop(context); // Close drawer
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
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text('Admin Panel',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', DashboardPage()),
            _buildDrawerItem(Icons.person, 'Users', UsersPage()),
            _buildDrawerItem(Icons.fastfood, 'Donations', DonationsPage()),
            _buildDrawerItem(Icons.list_alt, 'Requests', RequestsPage()),
            _buildDrawerItem(Icons.people, 'NGO Agents', AgentsPage()),
            _buildDrawerItem(Icons.campaign, 'Campaigns', CampaignsPage()),
            _buildDrawerItem(Icons.pie_chart, 'Reports', ReportsPage()),
            _buildDrawerItem(Icons.notifications, 'Notifications', NotificationsPage()),
            _buildDrawerItem(Icons.card_giftcard, 'Rewards', RewardsPage()),
            _buildDrawerItem(Icons.settings, 'Settings', SettingsPage()),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Add logout logic
              },
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

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Welcome to PlatePromise Admin Dashboard'));
  }
}

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Manage Users Here'));
  }
}

class DonationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Overview of Food Donations'));
  }
}

class RequestsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Donation Requests from Users'));
  }
}

class AgentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Manage NGO Agents and Volunteers'));
  }
}

class CampaignsPage extends StatefulWidget {
  @override
  _CampaignsPageState createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showAddCampaignDialog() {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Campaign'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Campaign Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: subtitleController,
                decoration: InputDecoration(
                  labelText: 'Campaign Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  subtitleController.text.isNotEmpty &&
                  imageUrlController.text.isNotEmpty) {
                try {
                  await _firestore.collection('Donation').add({
                    'title': titleController.text.trim(),
                    'subtitle': subtitleController.text.trim(),
                    'imageUrl': imageUrlController.text.trim(),
                    'isActive': true,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Campaign added successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding campaign: ${e.toString()}')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCampaignDialog(DocumentSnapshot campaign) {
    final titleController = TextEditingController(text: campaign['title']);
    final subtitleController = TextEditingController(text: campaign['subtitle']);
    final imageUrlController = TextEditingController(text: campaign['imageUrl']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Campaign'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Campaign Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: subtitleController,
                decoration: InputDecoration(
                  labelText: 'Campaign Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  subtitleController.text.isNotEmpty &&
                  imageUrlController.text.isNotEmpty) {
                try {
                  await _firestore.collection('campaigns').doc(campaign.id).update({
                    'title': titleController.text.trim(),
                    'subtitle': subtitleController.text.trim(),
                    'imageUrl': imageUrlController.text.trim(),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Campaign updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating campaign: ${e.toString()}')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _toggleCampaignStatus(DocumentSnapshot campaign) async {
    try {
      await _firestore.collection('campaigns').doc(campaign.id).update({
        'isActive': !campaign['isActive'],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            campaign['isActive'] ? 'Campaign deactivated' : 'Campaign activated',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating campaign: ${e.toString()}')),
      );
    }
  }

  void _deleteCampaign(DocumentSnapshot campaign) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Campaign'),
        content: Text('Are you sure you want to delete "${campaign['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('campaigns').doc(campaign.id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Campaign deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting campaign: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage Campaigns',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddCampaignDialog,
                  icon: Icon(Icons.add),
                  label: Text('Add Campaign'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('campaigns')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No campaigns found'));
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final campaign = snapshot.data!.docs[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(campaign['imageUrl']),
                              fit: BoxFit.cover,
                              onError: (error, stackTrace) {},
                            ),
                          ),
                          child: campaign['imageUrl'].isEmpty
                              ? Icon(Icons.image, color: Colors.grey)
                              : null,
                        ),
                        title: Text(
                          campaign['title'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              campaign['subtitle'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: campaign['isActive']
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    campaign['isActive'] ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _showEditCampaignDialog(campaign);
                                break;
                              case 'toggle':
                                _toggleCampaignStatus(campaign);
                                break;
                              case 'delete':
                                _deleteCampaign(campaign);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon(
                                    campaign['isActive']
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(campaign['isActive'] ? 'Deactivate' : 'Activate'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
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
        ],
      ),
    );
  }
}

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Analytics and Monthly Reports'));
  }
}

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Send and Manage App Notifications'));
  }
}

class RewardsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('User Rewards & Top-Ups'));
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('App Settings and Configuration'));
  }
}