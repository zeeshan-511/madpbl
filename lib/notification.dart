import 'package:flutter/material.dart';
import 'CustomBottomNav.dart';
import 'home_screen.dart';
import 'donation_page.dart';
import 'account_page.dart';
import 'notification_detail_page.dart';

class Notificationpage extends StatelessWidget {
  // REMOVE THIS LINE - This is causing your problem!
  // BuildContext? get context => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => Notificationpage()),
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
          else if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          }
        },
      ),
      backgroundColor: Color(0xFFD9B8FF), // Purple background
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                );
              },
            ),
            title: Text(
              'Notification',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.black),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Container(
                color: Colors.white,
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    _buildNotificationItem(context),  // Pass context here
                    SizedBox(height: 10),
                    _buildNotificationItem(context),  // Pass context here
                    SizedBox(height: 10),
                    _buildNotificationItem(context),  // Pass context here
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Update to accept context as parameter
  Widget _buildNotificationItem(BuildContext context) {
    return InkWell(
      onTap: () {
        print("Notification tapped");

        // Now using the passed context parameter
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NotificationDetailPage(
              title: "Donation has been sent to Social Project.",
              description: "Lorem ipsum dolor sit amet consectetur. Nunc imperdiet ornare aliquet enim. Additional details about this notification would appear here, providing the user with more context and information about the notification they received.",
              date: "5 Apr 2024",
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F6FF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.notifications, color: Colors.purple),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Donation has been sent to Social Project.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Lorem ipsum dolor sit amet consectetur. Nunc imperdiet ornare aliquet enim.",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "5 Apr 2024",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}