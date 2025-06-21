import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(MaterialApp(home: VolunteerSessionsPage()));

class VolunteerSessionsPage extends StatefulWidget {
  @override
  _VolunteerSessionsPageState createState() => _VolunteerSessionsPageState();
}

class _VolunteerSessionsPageState extends State<VolunteerSessionsPage> {
  late Database db;
  List<Map<String, dynamic>> sessions = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

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
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            location TEXT,
            date TEXT,
            time TEXT
          )
        ''');
      },
    );
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    final data = await db.query('sessions', orderBy: 'id DESC');
    setState(() {
      sessions = data;
    });
  }

  Future<void> insertSession() async {
    await db.insert('sessions', {
      'title': titleController.text,
      'description': descriptionController.text,
      'location': locationController.text,
      'date': dateController.text,
      'time': timeController.text,
    });
    clearFields();
    fetchSessions();
  }

  Future<void> updateSession(int id) async {
    await db.update(
      'sessions',
      {
        'title': titleController.text,
        'description': descriptionController.text,
        'location': locationController.text,
        'date': dateController.text,
        'time': timeController.text,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    clearFields();
    fetchSessions();
  }

  Future<void> deleteSession(int id) async {
    await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
    fetchSessions();
  }

  void clearFields() {
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    dateController.clear();
    timeController.clear();
  }

  void showSessionDialog({Map<String, dynamic>? session}) {
    if (session != null) {
      titleController.text = session['title'];
      descriptionController.text = session['description'];
      locationController.text = session['location'];
      dateController.text = session['date'];
      timeController.text = session['time'];
    }

    showDialog(
      context: this.context,
      builder: (ctx) => AlertDialog(
        title: Text(session == null ? 'Add Session' : 'Update Session'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              textField(titleController, 'Title'),
              textField(descriptionController, 'Description'),
              textField(locationController, 'Location'),
              textField(dateController, 'Date (YYYY-MM-DD)'),
              textField(timeController, 'Time (HH:MM AM/PM)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              clearFields();
              Navigator.pop(ctx);
            },
          ),
          ElevatedButton(
            child: Text(session == null ? "Add" : "Update"),
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  locationController.text.isNotEmpty &&
                  dateController.text.isNotEmpty &&
                  timeController.text.isNotEmpty) {
                if (session == null) {
                  insertSession();
                } else {
                  updateSession(session['id']);
                }
                Navigator.pop(ctx);
              }
            },
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
        title: Text("Volunteer Sessions"),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        onPressed: () => showSessionDialog(),
      ),
      body: sessions.isEmpty
          ? Center(child: Text("No sessions yet"))
          : ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (ctx, index) {
          final s = sessions[index];
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => showSessionDialog(session: s),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteSession(s['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
