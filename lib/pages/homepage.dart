// lib/homepage.dart
import 'package:flutter/material.dart';
import 'notes_page.dart';
import 'timetable_page.dart';
import 'todo_page.dart';
// Import other dependencies or internal packages as needed.

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotesPage()),
                );
              },
              child: Text('Notes'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimetablePage()),
                );
              },
              child: Text('Timetable'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ToDoPage()),
                );
              },
              child: Text('To-Do'),
            ),
          ],
        ),
      ),
    );
  }
}