// File: lib/note_detail_page.dart
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;
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
  //late TextEditingController _contentController;
  // Access your organization's settings storage if needed
  final _notesBox = Hive.box<Note>('notes');
  final _settingsBox = Hive.box('settings');
  bool _isAutosaveEnabled = false;
  late String _initialContent;
  late quill.QuillController _controller;

  @override
  void initState() {
    super.initState();

    _initialContent = widget.note.content;

    // Initialize the QuillController based on existing content
    if (widget.note.content.isNotEmpty) {
      try {
        // Try to decode the existing content as Delta (JSON)
        var myJson = jsonDecode(widget.note.content);
        var document = quill.Document.fromJson(myJson);
        _controller = quill.QuillController(
          document: document,
          selection: TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // If decoding fails, treat content as plain text
        var document = quill.Document()..insert(0, widget.note.content);
        _controller = quill.QuillController(
          document: document,
          selection: TextSelection.collapsed(offset: 0),
        );
      }
    } else {
      // For new notes or empty content
      _controller = quill.QuillController.basic();
    }

    // Retrieve the autosave preference from the settings box
    _isAutosaveEnabled = _settingsBox.get('autosaveEnabled', defaultValue: false);

    // Initialize autosave if it's enabled
    if (_isAutosaveEnabled) {
      _controller.addListener(_autosave);
    }
  }

  @override
  void dispose() {
    // Remove the listener if autosave is enabled
    if (_isAutosaveEnabled) {
      _controller.removeListener(_autosave);
    }
    _controller.dispose();
    super.dispose();
  }

  void _saveContent() {
    // Serialize the document to JSON
    String content = jsonEncode(_controller.document.toDelta().toJson());
    widget.note.content = content;
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
      _controller.addListener(_autosave);
    } else {
      _controller.removeListener(_autosave);
    }
  }

  Future<bool> _onWillPop() async {
    String currentContent = jsonEncode(_controller.document.toDelta().toJson());

    if (!_isAutosaveEnabled && currentContent != _initialContent) {
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
      return shouldLeave ?? false;
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
        body: Column(
          children: [
            
            // Quill Toolbar
            quill.QuillSimpleToolbar(
              controller: _controller,
              configurations: const quill.QuillSimpleToolbarConfigurations(),
            ),
            // Quill Editor
            Expanded(
              child: quill.QuillEditor.basic(
                controller: _controller,
                configurations: const quill.QuillEditorConfigurations(),
                focusNode: FocusNode(),
                scrollController: ScrollController(),
              )
            ),
          ],
        ),
      ),
    );
  }
}