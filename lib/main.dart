// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/task.dart';
import 'models/event.dart';
import 'models/notes.dart';
import 'pages/homepage.dart';
import 'pages/todo_page.dart';
import 'pages/timetable_page.dart';
import 'pages/notes_page.dart';

// Import other dependencies or internal packages as needed.


void main() async {
  // Ensures that plugin services are initialized before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with Flutter support
  await Hive.initFlutter();

  // Register the Task adapter
  if (!Hive.isAdapterRegistered (TaskAdapter().typeId)) {
    Hive.registerAdapter(TaskAdapter());
  }
  if (!Hive.isAdapterRegistered (EventAdapter().typeId)) {
    Hive.registerAdapter(EventAdapter());
  }
  if (!Hive.isAdapterRegistered (TimePeriodAdapter().typeId)) {
    Hive.registerAdapter(TimePeriodAdapter());
  }
  if (!Hive.isAdapterRegistered (NoteAdapter().typeId)) {
    Hive.registerAdapter(NoteAdapter());
  }

  // Open the Hive box for tasks



  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Event>('events');
  await Hive.openBox<Note>('notes');
  await Hive.openBox('settings');

  // Run the Flutter application
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    //_clearHiveBoxes();
  }

  Future<void> _clearHiveBoxes() async {
    var tasksBox = await Hive.openBox('tasks');
    var eventsBox = await Hive.openBox('events');
    var notesBox = await Hive.openBox('notes');

    await tasksBox.clear();
    await eventsBox.clear();
    await notesBox.clear();
  }

  @override
  void dispose() {
    // Remove the observer and close Hive
    WidgetsBinding.instance.removeObserver(this);
    Hive.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // Optionally close Hive when the app is paused
        Hive.close();
        break;
      case AppLifecycleState.resumed:
        // Optionally reopen Hive when the app is resumed
        Hive.openBox<Task>('tasks');
        break;
      default:
        break;
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), // Set HomePage as the initial screen
      routes: {
        '/todo': (context) => TodoPage(),
        '/timetable': (context) => TimetablePage(),
        '/notes': (context) => NotesPage(),
      },
    );
  }
}