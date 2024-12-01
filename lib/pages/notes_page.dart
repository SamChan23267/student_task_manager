// File: lib/notes_page.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/notes.dart';
import 'notes_detail_page.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _notesBox = Hive.box<Note>('notes');
  final _titleController = TextEditingController();

  void _addNote() {
    final title = _titleController.text.trim();

    if (title.isNotEmpty) {
      final note = Note(
        title: title,
      );
      _notesBox.add(note);
      _titleController.clear();
      Navigator.of(context).pop();
    }
  }

  void _deleteNote(int index) {
    _notesBox.deleteAt(index);
  }

  void _openNoteDetail(Note note, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteDetailPage(
          note: note,
          index: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: ValueListenableBuilder(
        valueListenable: _notesBox.listenable(),
        builder: (context, Box<Note> box, _) {
          if (box.values.isEmpty) {
            return Center(
              child: Text('No notes yet'),
            );
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final note = box.getAt(index);
              return ListTile(
                title: Text(note?.title ?? ''),
                onTap: () => _openNoteDetail(note!, index),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteNote(index),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Add Note'),
            content: TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            actions: [
              TextButton(
                onPressed: _addNote,
                child: Text('Save'),
              ),
            ],
          ),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}