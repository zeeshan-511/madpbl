import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UserVolunteerSessionsPage extends StatefulWidget {
  @override
  _UserVolunteerSessionsPageState createState() => _UserVolunteerSessionsPageState();
}

class _UserVolunteerSessionsPageState extends State<UserVolunteerSessionsPage> {
  late Database db;
  List<Map<String, dynamic>> sessions = [];
  Set<int> registeredSessions = {}; // Track registered sessions

  @override
  void initState() {
    super.initState();
    initDb();
  }

  Future<void> initDb() async {
    final dbPath = await getDatabasesPath();
    db = await openDatabase(
      join(dbPath, 'sessions.db'),
      version: 1,
      onCreate: (Database database, int version) async {
        await database.execute('''
          CREATE TABLE IF NOT EXISTS sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            location TEXT,
            date TEXT,
            time TEXT
          )
        ''');
        await database.execute('''
          CREATE TABLE IF NOT EXISTS registrations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sessionId INTEGER,
            name TEXT,
            email TEXT,
            phone TEXT
          )
        ''');
      },
    );
    fetchSessions();
    fetchRegistrations(); // Load existing registrations
  }

  Future<void> fetchSessions() async {
    final data = await db.query('sessions', orderBy: 'id DESC');
    setState(() {
      sessions = data;
    });
  }

  Future<void> fetchRegistrations() async {
    final data = await db.query('registrations', columns: ['sessionId']);
    setState(() {
      registeredSessions = data.map((row) => row['sessionId'] as int).toSet();
    });
  }

  Future<void> registerUser(int sessionId, String name, String email, String phone) async {
    await db.insert('registrations', {
      'sessionId': sessionId,
      'name': name,
      'email': email,
      'phone': phone,
    });

    setState(() {
      registeredSessions.add(sessionId);
    });

    ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
      content: Text("Successfully registered!"),
      duration: Duration(seconds: 2),
    ));
  }

  void showRegistrationForm(int sessionId) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: this.context,
      builder: (ctx) => AlertDialog(
        title: Text("Register for Session"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              textField(nameController, "Full Name"),
              textField(emailController, "Email"),
              textField(phoneController, "Phone Number"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty) {
                registerUser(sessionId, name, email, phone);
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                  content: Text("Please fill all fields."),
                  duration: Duration(seconds: 2),
                ));
              }
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }

  Widget textField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Volunteer Sessions"),
        backgroundColor: Colors.deepPurple,
      ),
      body: sessions.isEmpty
          ? Center(child: Text("No sessions available"))
          : ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (ctx, index) {
          final s = sessions[index];
          final sessionId = s['id'] as int;
          final isRegistered = registeredSessions.contains(sessionId);

          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(s['title'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Description: ${s['description']}"),
                  Text("Location: ${s['location']}"),
                  Text("Date: ${s['date']}"),
                  Text("Time: ${s['time']}"),
                ],
              ),
              trailing: isRegistered
                  ? Text(
                  "✓ Registered",
                  style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold
                  )
              )
                  : ElevatedButton(
                onPressed: () => showRegistrationForm(sessionId),
                child: Text("Register"),
              ),
            ),
          );
        },
      ),
    );
  }
}