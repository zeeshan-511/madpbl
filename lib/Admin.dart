import 'package:flutter/material.dart';

void main() {
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

class CampaignsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Create & Manage Awareness Campaigns'));
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
