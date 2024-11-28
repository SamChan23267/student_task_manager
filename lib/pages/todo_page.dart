// lib/pages/todo_page.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _formKey = GlobalKey<FormState>();
  late Box<Task> taskBox;

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box<Task>('tasks');
  }

  void _addTask() {
    String title = '';
    String description = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Task'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                onSaved: (value) => title = value!.trim(),
                validator: (value) =>
                    value != null && value.trim().isNotEmpty
                        ? null
                        : 'Enter a title',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value!.trim(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final task = Task(
                  title: title,
                  description: description,
                );
                taskBox.add(task);
                Navigator.of(context).pop(); // Close the dialog
                setState(() {});
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editTask(int index, Task task) {
    String title = task.title;
    String description = task.description;
    final _editFormKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Task'),
        content: Form(
          key: _editFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: task.title,
                decoration: InputDecoration(labelText: 'Title'),
                onSaved: (value) => title = value!.trim(),
                validator: (value) =>
                    value != null && value.trim().isNotEmpty
                        ? null
                        : 'Enter a title',
              ),
              TextFormField(
                initialValue: task.description,
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value!.trim(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_editFormKey.currentState!.validate()) {
                _editFormKey.currentState!.save();
                final updatedTask = Task(
                  title: title,
                  description: description,
                  isCompleted: task.isCompleted,
                );
                taskBox.putAt(index, updatedTask);
                Navigator.of(context).pop(); // Close the dialog
                setState(() {});
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content:
            Text('Are you sure you want to delete "${taskBox.getAt(index)!.title}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              taskBox.deleteAt(index);
              Navigator.of(context).pop(); // Close the dialog
              setState(() {});
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleTaskStatus(int index, Task task) {
    final updatedTask = Task(
      title: task.title,
      description: task.description,
      isCompleted: !task.isCompleted,
    );
    taskBox.putAt(index, updatedTask);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tasks = taskBox.values.toList().cast<Task>();

    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: tasks.isEmpty
          ? Center(child: Text('No tasks added yet.'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: EdgeInsets.symmetric(horizontal: 20), child: Icon(Icons.delete, color: Colors.white)),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Task'),
                        content: Text(
                            'Are you sure you want to delete "${task.title}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    _deleteTask(index);
                  },
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(
                        task.isCompleted
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: task.isCompleted ? Colors.green : null,
                      ),
                      onPressed: () => _toggleTaskStatus(index, task),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle:
                        task.description.isNotEmpty ? Text(task.description) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          tooltip: 'Edit',
                          onPressed: () => _editTask(index, task),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          tooltip: 'Delete',
                          onPressed: () => _deleteTask(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add Task',
        child: Icon(Icons.add),
      ),
    );
  }
}