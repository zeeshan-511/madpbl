import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madpbl/notification.dart';
import 'CustomBottomNav.dart';
import 'account_page.dart';
import 'home_screen.dart';
import 'donate_foodpage.dart'; // adjust if path differs


const primaryPurple = Color(0xFF7E57C2);

class Donation {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final bool isActive;
  final double amount;
  final String daysLeft;

  Donation({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.isActive,
    this.amount = 0.0,
    this.daysLeft = '30 days to go',
  });

  factory Donation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Donation(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      isActive: data['isActive'] ?? true,
      amount: (data['amount'] ?? 0.0).toDouble(),
      daysLeft: data['daysLeft'] ?? '30 days to go',
    );
  }
}

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({Key? key}) : super(key: key);

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  void _showDonationFormDialog(Donation campaign) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Donate to "${campaign.title}"'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Your Name'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Donation Amount'),
              ),
              TextField(
                controller: messageController,
                decoration: InputDecoration(labelText: 'Message (optional)'),
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
              if (nameController.text.isEmpty || amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill in all required fields')),
                );
                return;
              }

              await FirebaseFirestore.instance.collection('Donations').add({
                'campaignId': campaign.id,
                'campaignTitle': campaign.title,
                'donorName': nameController.text.trim(),
                'amount': double.tryParse(amountController.text) ?? 0.0,
                'message': messageController.text.trim(),
                'timestamp': FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Donation submitted successfully!')),
              );
            },
            child: Text('Donate'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DonationsScreen()),
            );
          } else if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) =>  Notificationpage()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AccountPage()),
            );
          }
        },
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFCEA7F3), Colors.white],
                stops: [0.0, 0.4],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top app bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                          );
                        },
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Donations',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // White container with rounded top
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Search bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Icon(Icons.search, color: Colors.grey),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value.toLowerCase();
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Search campaign',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.filter_list,
                                      color: Colors.grey),
                                  onPressed: () {
                                    // Filter functionality
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // StreamBuilder to display donations
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Donation')
                                .where('isActive', isEqualTo: true)
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return const Center(
                                  child: Text(
                                    'Error loading campaigns',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.campaign,
                                          size: 64, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text(
                                        'No campaigns available',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              List<Donation> campaigns = snapshot.data!.docs
                                  .map((doc) =>
                                  Donation.fromFirestore(doc))
                                  .where((campaign) =>
                              _searchQuery.isEmpty ||
                                  campaign.title
                                      .toLowerCase()
                                      .contains(_searchQuery) ||
                                  campaign.subtitle
                                      .toLowerCase()
                                      .contains(_searchQuery))
                                  .toList();

                              if (campaigns.isEmpty &&
                                  _searchQuery.isNotEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No campaigns found for "$_searchQuery"',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // Show the list of campaigns
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                itemCount: campaigns.length,
                                itemBuilder: (context, index) {
                                  final campaign = campaigns[index];
                                  return Card(
                                    elevation: 2,
                                    margin:
                                    const EdgeInsets.only(bottom: 12.0),
                                    child: ListTile(
                                      leading: Image.network(
                                        campaign.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                        const Icon(
                                            Icons.image_not_supported),
                                      ),
                                      title: Text(campaign.title),
                                      subtitle: Text(campaign.subtitle),
                                      trailing: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '\$${campaign.amount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            campaign.daysLeft,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      onTap: () => _showDonationFormDialog(campaign),

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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
