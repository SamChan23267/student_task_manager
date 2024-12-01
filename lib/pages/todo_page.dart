import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // Import for date formatting
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

  // Debug function to print all tasks
  void _printAllTasks() {
    final tasks = taskBox.values.toList().cast<Task>();
    for (var task in tasks) {
      debugPrint('Title: ${task.title}');
      debugPrint('Description: ${task.description}');
      debugPrint('Completed: ${task.isCompleted}');
      debugPrint('Due Date: ${task.dueDate}');
      debugPrint('-----------------------------');
    }
  }

  void _addTask() {
    String title = '';
    String description = '';
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Task'),
              content: SingleChildScrollView(
                child: Form(
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
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dueDate == null
                                  ? 'No date chosen'
                                  : 'Due: ${DateFormat.yMd().add_jm().format(dueDate!)}',
                              style: TextStyle(
                                color: dueDate == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: dueDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (selectedDate != null) {
                                final selectedTime = await showTimePicker(
                                  context: context,
                                  initialTime: dueDate != null
                                      ? TimeOfDay.fromDateTime(dueDate!)
                                      : TimeOfDay.now(),
                                );
                                if (selectedTime != null) {
                                  setState(() {
                                    dueDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    );
                                  });
                                }
                              }
                            },
                            child: Text('Select Date & Time'),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                        dueDate: dueDate,
                      );
                      taskBox.add(task);
                      Navigator.of(context).pop(); // Close the dialog
                      setState(() {});
                      _printAllTasks(); // Print all tasks for verification
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editTask(int index, Task task) {
    String title = task.title;
    String description = task.description;
    DateTime? dueDate = task.dueDate;
    final _editFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Task'),
              content: SingleChildScrollView(
                child: Form(
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
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dueDate == null
                                  ? 'No date chosen'
                                  : 'Due: ${DateFormat.yMd().add_jm().format(dueDate!)}',
                              style: TextStyle(
                                color: dueDate == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: dueDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (selectedDate != null) {
                                final selectedTime = await showTimePicker(
                                  context: context,
                                  initialTime: dueDate != null
                                      ? TimeOfDay.fromDateTime(dueDate!)
                                      : TimeOfDay.now(),
                                );
                                if (selectedTime != null) {
                                  setState(() {
                                    dueDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    );
                                  });
                                }
                              }
                            },
                            child: Text('Select Date & Time'),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                        dueDate: dueDate,
                      );
                      taskBox.putAt(index, updatedTask);
                      Navigator.of(context).pop(); // Close the dialog
                      setState(() {});
                      _printAllTasks(); // Print all tasks for verification
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
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
              _printAllTasks(); // Print all tasks for verification
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
      dueDate: task.dueDate,
    );
    taskBox.putAt(index, updatedTask);
    setState(() {});
    _printAllTasks(); // Print all tasks for verification
  }

  @override
  Widget build(BuildContext context) {
    final tasks = taskBox.values.toList().cast<Task>();

    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            tooltip: 'Print All Tasks',
            onPressed: _printAllTasks,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: taskBox.listenable(),
        builder: (context, Box<Task> box, _) {
          if (box.values.isEmpty) {
            return Center(child: Text('No tasks added yet.'));
          }

          final tasks = box.values.toList().cast<Task>();
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Dismissible(
                key: UniqueKey(),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (task.description.isNotEmpty)
                        Text(task.description),
                      if (task.dueDate != null)
                        Text(
                          'Due: ${DateFormat.yMd().add_jm().format(task.dueDate!)}',
                          style: TextStyle(
                            color:
                                task.isCompleted ? Colors.grey : Colors.black,
                          ),
                        ),
                    ],
                  ),
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