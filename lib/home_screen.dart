import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CustomBottomNav.dart';
import 'donation_page.dart';
import 'account_page.dart';
import 'notification.dart';
import 'donate_foodpage.dart';
import'Request_food.dart';
import 'user_sessions_page.dart';
import 'contact_us_page.dart';
import 'topup_balance_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Donation {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final bool isActive;

  Donation({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.isActive,
  });

  factory Donation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Donation(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedActionCardIndex = -1;
  late Future<double> _balanceFuture;

  @override
  void initState() {
    super.initState();
    _balanceFuture = _fetchDonationBalance();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _balanceFuture = _fetchDonationBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            return;
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
      backgroundColor: const Color(0xFFF7F5FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F5FA),
        elevation: 0,
        title: const Text(
          'PlatePromise',
          style: TextStyle(
            color: Colors.deepPurpleAccent,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: _buildHomeContent(),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6D8FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Help families in village by donating food',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DonationsScreen()),
                    );
                  },
                  child: const Text('Donate Now'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text('\$125.00 funds collected | 20 days left'),
                    Spacer(),
                    Text('25%'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Donation balance:'),
                    const SizedBox(height: 5),
                    FutureBuilder<double>(
                      future: _balanceFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        } else if (snapshot.hasError) {
                          return const Text("Error fetching balance");
                        } else {
                          final balance = snapshot.data ?? 0.0;
                          return Text(
                            '\$${balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TopUpBalancePage()),
                    );
                    setState(() {
                      _balanceFuture = _fetchDonationBalance();
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Top up Balance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6D8FB),
                    foregroundColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Become a Food Donor Today',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                buildActionCard(Icons.food_bank, 'Donate Food', 0),
                buildActionCard(Icons.request_page, 'Request Food', 1),
                buildActionCard(Icons.volunteer_activism, 'Volunteer Sessions', 2),
                buildActionCard(Icons.contact_emergency, 'Help and Contact', 3),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Latest News',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Donation')
                .where('isActive', isEqualTo: true)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error loading campaigns'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No campaigns available'));
              }

              List<Donation> campaigns = snapshot.data!.docs
                  .map((doc) => Donation.fromFirestore(doc))
                  .toList();

              return Column(
                children: campaigns
                    .map((campaign) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DonationsScreen(),
                      ),
                    );
                  },
                  child: buildCampaignCard(
                    campaign.imageUrl,
                    campaign.title,
                    campaign.subtitle,
                  ),
                ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildActionCard(IconData icon, String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedActionCardIndex = index;
        });

        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DonateFoodPage()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RequestFoodPage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserVolunteerSessionsPage()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactUsPage()),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: _selectedActionCardIndex == index
                    ? Colors.deepPurple
                    : Colors.grey,
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCampaignCard(String imageUrl, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: imageUrl.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          ),
        )
            : const Icon(Icons.image, size: 40, color: Colors.grey),
        title: Text(title),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

Future<double> _fetchDonationBalance() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 0.0;

  double totalTopUps = 0.0;
  double totalTransfers = 0.0;

  final topupsSnap = await FirebaseFirestore.instance
      .collection('topups')
      .where('email', isEqualTo: user.email)
      .get();
  for (var doc in topupsSnap.docs) {
    totalTopUps += double.tryParse(doc['amount'].toString()) ?? 0.0;
  }

  final transfersSnap = await FirebaseFirestore.instance
      .collection('transfers')
      .where('email', isEqualTo: user.email)
      .get();
  for (var doc in transfersSnap.docs) {
    totalTransfers += double.tryParse(doc['amount'].toString()) ?? 0.0;
  }

  return totalTopUps - totalTransfers;
}
