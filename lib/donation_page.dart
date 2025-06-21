import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madpbl/TransferHistory.dart';
import 'CustomBottomNav.dart';
import 'account_page.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  double userBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserBalance();
  }

  Future<void> _fetchUserBalance() async {
    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection('Users').doc('user1').get();
    setState(() {
      userBalance = (snapshot['balance'] ?? 0.0).toDouble();
    });
  }

  void _showDonationFormDialog(Donation campaign) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final messageController = TextEditingController();

    // 1. Fetch current balance
    double availableBalance = 0.0;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      double totalTopUps = 0.0, totalTransfers = 0.0;

      final topupsSnap = await FirebaseFirestore.instance
          .collection('topups')
          .where('email', isEqualTo: user.email)
          .get();
      for (var doc in topupsSnap.docs) {
        totalTopUps += (doc['amount'] ?? 0.0).toDouble();
      }

      final transfersSnap = await FirebaseFirestore.instance
          .collection('transfers')
          .where('email', isEqualTo: user.email)
          .get();
      for (var doc in transfersSnap.docs) {
        totalTransfers += (doc['amount'] ?? 0.0).toDouble();
      }

      availableBalance = totalTopUps - totalTransfers;
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Send Funds to "${campaign.title}"'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Balance: \$${availableBalance.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Your Name'),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount to Send'),
                  onChanged: (_) {
                    setStateDialog(() {}); // Refresh remaining balance display if needed
                  },
                ),
                const SizedBox(height: 10),
                Builder(
                  builder: (_) {
                    final entered = double.tryParse(amountController.text) ?? 0.0;
                    final remaining = (availableBalance - entered).toStringAsFixed(2);
                    return Text(
                      'Remaining Balance: \$${remaining}',
                      style: TextStyle(
                        color: (availableBalance - entered) < 0 ? Colors.red : Colors.black,
                      ),
                    );
                  },
                ),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(labelText: 'Message (optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final enteredAmount = double.tryParse(amountController.text.trim()) ?? 0.0;

                if (nameController.text.isEmpty || enteredAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid name and amount')),
                  );
                  return;
                }
                if (enteredAmount > availableBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Insufficient balance')),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance.collection('Donations').add({
                    'campaignId': campaign.id,
                    'campaignTitle': campaign.title,
                    'donorName': nameController.text.trim(),
                    'amount': enteredAmount,
                    'message': messageController.text.trim(),
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  await FirebaseFirestore.instance.collection('transfers').add({
                    'email': user?.email,
                    'donorName': nameController.text.trim(),
                    'campaignId': campaign.id,
                    'campaignTitle': campaign.title,
                    'campaignSubtitle': campaign.subtitle,
                    'imageUrl': campaign.imageUrl,
                    'amount': enteredAmount,
                    'message': messageController.text.trim(),
                    'timestamp': FieldValue.serverTimestamp(),
                  });


                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funds sent successfully!')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Send Funds'),
            ),
          ],
        ),
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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DonationsScreen()));
          } else if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => TransferHistoryPage()));
          } else if (index == 3) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const AccountPage()));
          }
        },
      ),
      body: Stack(
        children: [
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()));
                        },
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Donations',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
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
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
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
                                return const Center(
                                  child: Text('Error loading campaigns',
                                      style: TextStyle(color: Colors.red)),
                                );
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.campaign, size: 64, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text('No campaigns available',
                                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                                    ],
                                  ),
                                );
                              }

                              List<Donation> campaigns = snapshot.data!.docs
                                  .map((doc) => Donation.fromFirestore(doc))
                                  .where((campaign) =>
                              _searchQuery.isEmpty ||
                                  campaign.title
                                      .toLowerCase()
                                      .contains(_searchQuery) ||
                                  campaign.subtitle
                                      .toLowerCase()
                                      .contains(_searchQuery))
                                  .toList();

                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: campaigns.length,
                                itemBuilder: (context, index) {
                                  final campaign = campaigns[index];
                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.only(bottom: 12.0),
                                    child: ListTile(
                                      leading: Image.network(
                                        campaign.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
                                      ),
                                      title: Text(campaign.title),
                                      subtitle: Text(campaign.subtitle),
                                      trailing: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('\$${campaign.amount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text(campaign.daysLeft,
                                              style: const TextStyle(
                                                  fontSize: 12, color: Colors.grey)),
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
