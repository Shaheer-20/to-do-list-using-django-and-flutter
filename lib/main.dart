import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  List<dynamic> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/api/tasks/'));

    if (response.statusCode == 200) {
      setState(() {
        tasks = json.decode(response.body)['tasks'];
      });
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> addTask(String task) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/tasks/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'task': task}),
    );

    if (response.statusCode == 201) {
      fetchTasks(); // Refresh task list after adding
    } else {
      throw Exception('Failed to add task');
    }
  }

  Future<void> editTask(int id, String updatedTask) async {
    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/tasks/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'task': updatedTask}),
    );

    if (response.statusCode == 200) {
      fetchTasks(); // Refresh task list after editing
    } else {
      throw Exception('Failed to edit task');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/api/tasks/$id/'),
    );

    if (response.statusCode == 200) {
      fetchTasks(); // Refresh task list after deletion
    } else {
      throw Exception('Failed to delete task');
    }
  }

  void _showAddTaskDialog() {
    String newTask = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            onChanged: (value) {
              newTask = value;
            },
            decoration: const InputDecoration(hintText: 'Enter task'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (newTask.isNotEmpty) {
                  addTask(newTask);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(int id, String currentTask) {
    String updatedTask = currentTask;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: TextEditingController(text: currentTask),
            onChanged: (value) {
              updatedTask = value;
            },
            decoration: const InputDecoration(hintText: 'Edit task'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (updatedTask.isNotEmpty && updatedTask != currentTask) {
                  editTask(id, updatedTask);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tasks[index]['task']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditTaskDialog(
                        tasks[index]['id'], tasks[index]['task']);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    deleteTask(tasks[index]['id']);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
