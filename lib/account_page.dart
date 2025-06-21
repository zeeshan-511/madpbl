import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:madpbl/donate_foodpage.dart';
import 'package:madpbl/home_screen.dart';
import 'package:madpbl/TransferHistory.dart';
import 'package:madpbl/orgotPasswordScreen.dart';
import 'CustomBottomNav.dart';
import 'Signinpage.dart';
import 'donation_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_page.dart'; // Import the new edit profile page
import 'AboutUsPage.dart';
import 'donation_history_page.dart';
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? currentUser;
  bool isLoading = true;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String? _uploadedImageUrl;
  String _displayName = 'Username'; // Store display name locally

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    String? imageUrl;
    String? name;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      imageUrl = doc.data()?['profileImage'];
      name = doc.data()?['displayName'] ?? user.displayName; // Prioritize Firestore, then Auth
    }

    setState(() {
      currentUser = user;
      _uploadedImageUrl = imageUrl ?? user?.photoURL;
      _displayName = name ?? 'Username'; // Set local display name
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      await _uploadToCloudinary(_profileImage!);
    }
  }

  Future<void> _uploadToCloudinary(File imageFile) async {
    const cloudName = 'dbscg7kjc';
    const uploadPreset = 'flutter_unsigned';

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStream = await response.stream.bytesToString();
      final data = json.decode(resStream);

      final imageUrl = data['secure_url'];

      setState(() {
        _uploadedImageUrl = imageUrl;
      });

      // ✅ Update Firebase Auth profile photo
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(imageUrl);

      // ✅ Store image URL in Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {
            'profileImage': imageUrl,
          },
          SetOptions(merge: true),
        );
      }
    } else {
      print('Failed to upload image to Cloudinary. Status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3,
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
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => TransferHistoryPage()),
            );
          }
        },
      ),
      backgroundColor: const Color(0xFFF7F5FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCEA7F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        title: const Text(
          'Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentUser == null
          ? _buildNotLoggedInView()
          : _buildUserProfileView(),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Please log in to view your account',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: const Color(0xFFCEA7F3),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("Go to Login"),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileView() {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFCEA7F3),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: _uploadedImageUrl != null
                        ? NetworkImage(_uploadedImageUrl!)
                        : const AssetImage('assets/default_profile.jpg') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.deepPurple,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _displayName, // Use local _displayName
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              Text(
                currentUser?.email ?? 'No email provided',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Navigate to EditProfilePage
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(
                            currentDisplayName: _displayName,
                          ),
                        ),
                      );

                      // If a change was made and saved, reload user data to reflect it
                      if (result == true) {
                        await _loadUser();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _ListTileItem(
                icon: Icons.favorite,
                title: 'My donation',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DonationHistoryPage()),
                  );
                },
              ),
              _ListTileItem(
                icon: Icons.food_bank,
                title: 'Donate Food',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DonateFoodPage()),
                  );
                },
              ),
              _ListTileItem(
                icon: Icons.vpn_key,
                title: 'Forget Password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                  );
                },
              ),
              _ListTileItem(
                icon: Icons.info,
                title: 'About Us',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutUsPage()),
                  );
                },
              ),
              _ListTileItem(
                icon: Icons.logout,
                title: 'Log out',
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  setState(() {
                    currentUser = null;
                    _uploadedImageUrl = null;
                    _displayName = 'Username'; // Reset display name
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListTileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _ListTileItem({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.deepPurple),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 0),
      ],
    );
  }
}
