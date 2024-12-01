// File: lib/note_detail_page.dart
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../models/notes.dart';


class NoteDetailPage extends StatefulWidget {
  final Note note;
  final int index;

  NoteDetailPage({
    required this.note,
    required this.index,
  });

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _contentController;
  // Access your organization's settings storage if needed
  final _notesBox = Hive.box<Note>('notes');
  final _settingsBox = Hive.box('settings');
  bool _isAutosaveEnabled = false;
  late String _initialContent;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.note.content);
    _initialContent = widget.note.content;

    // Retrieve the autosave preference from the settings box
    _isAutosaveEnabled = _settingsBox.get('autosaveEnabled', defaultValue: false);

    // Initialize autosave if it's enabled
    if (_isAutosaveEnabled) {
      _contentController.addListener(_autosave);
    }
  }

  @override
  void dispose() {
    // Remove the listener if autosave is enabled
    if (_isAutosaveEnabled) {
      _contentController.removeListener(_autosave);
    }
    _contentController.dispose();
    super.dispose();
  }

  void _saveContent() {
    widget.note.content = _contentController.text;
    _notesBox.putAt(widget.index, widget.note);
    _initialContent = widget.note.content; // Update initial content after saving
  }

  void _autosave() {
    _saveContent();
  }

  void _toggleAutosave(bool value) {
    setState(() {
      _isAutosaveEnabled = value;
      _settingsBox.put('autosaveEnabled', _isAutosaveEnabled);
    });

    if (_isAutosaveEnabled) {
      _contentController.addListener(_autosave);
    } else {
      _contentController.removeListener(_autosave);
    }
  }

Future<bool> _onWillPop() async {
  if (!_isAutosaveEnabled && _contentController.text != _initialContent) {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unsaved Changes'),
        content: Text('You have unsaved changes. Do you want to save before exiting?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Don't Save and exit
            },
            child: Text('Don\'t Save'),
          ),
          TextButton(
            onPressed: () {
              _saveContent();
              Navigator.of(context).pop(true); // Save and exit
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Cancel and stay
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
    return shouldLeave ?? false; // Allow or prevent navigation based on the user's choice
  } else {
    return true; // No unsaved changes, allow navigation
  }
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.note.title),
          actions: [
            // Autosave toggle switch
            Row(
              children: [
                Text('Autosave'),
                Switch(
                  value: _isAutosaveEnabled,
                  onChanged: _toggleAutosave,
                ),
              ],
            ),
            if (!_isAutosaveEnabled)
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () {
                  _saveContent();
                  // Display a SnackBar message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Saved successfully!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
          ],
        ),
        body: Container(
          color: Colors.white,
          child: TextField(
            controller: _contentController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            expands: true,
            style: TextStyle(fontSize: 18.0, height: 1.5),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(16.0),
              hintText: 'Enter your notes here...',
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
