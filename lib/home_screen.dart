import 'package:flutter/material.dart';
import 'CustomBottomNav.dart';
import 'donation_page.dart';
import 'account_page.dart';
import 'notification.dart';
class Campaign {
  final String imageAsset;
  final String title;
  final String subtitle;

  Campaign({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedActionCardIndex = -1;

  // List of campaigns with non-nullable values
  final List<Campaign> campaigns = [
    Campaign(
      imageAsset: 'assets/c1.jpeg',
      title: 'Share Food in Pakistan',
      subtitle: 'Donate excess food to help feed those in need in your community.',
    ),
    Campaign(
      imageAsset: 'assets/c2.jpeg',
      title: 'Winter Clothing Drive',
      subtitle: 'Help keep people warm this winter by donating coats and warm clothing.',
    ),
    Campaign(
      imageAsset: 'assets/c3.jpeg',
      title: 'Books for Children',
      subtitle: 'Donate books to help children in underprivileged schools.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
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
          else if (index == 2) {
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.card_giftcard, size: 16),
              label: const Text('Rewards'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE6D8FB),
                foregroundColor: Colors.deepPurple,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
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
          // Spotlight Section
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
                  onPressed: () {},
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
          // Donation Balance Section
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Donation balance:'),
                    SizedBox(height: 5),
                    Text(
                      '\$215.00',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
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
          // Become a Food Donor Section
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
                buildActionCard(Icons.local_shipping, 'NGO Agent', 2),
                buildActionCard(Icons.group, 'Community', 3),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Latest Campaigns Section
          const Text(
            'Latest News',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          // Campaign Cards List
          Column(
            children: campaigns.map((campaign) => buildCampaignCard(
              campaign.imageAsset,
              campaign.title,
              campaign.subtitle,
            )).toList(),
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

  Widget buildCampaignCard(String imageAsset, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(imageAsset),
              fit: BoxFit.cover,
            ),
          ),
        ),
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