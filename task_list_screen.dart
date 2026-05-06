import 'package:flutter/material.dart';
import '../models/task.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  bool isDark = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadTheme();
  }

  /// ================= TASK STORAGE =================

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList("tasks", data);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList("tasks");

    if (data != null) {
      setState(() {
        tasks = data.map((e) => Task.fromJson(jsonDecode(e))).toList();
      });
    }
  }

  /// ================= THEME =================

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDark", isDark);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = prefs.getBool("isDark") ?? false;
    });
  }

  /// ================= ACTIONS =================

  Future<void> _addTask() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );

    if (newTask != null) {
      setState(() => tasks.add(newTask));
      _saveTasks();
    }
  }

  Future<void> _openTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(task: task),
      ),
    );

    if (result == "delete") {
      setState(() => tasks.removeWhere((t) => t.id == task.id));
      _saveTasks();
    } else if (result is Task) {
      setState(() {
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) tasks[index] = result;
      });
      _saveTasks();
    }
  }

  void _deleteTask(int index) {
    setState(() => tasks.removeAt(index));
    _saveTasks();
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Робота":
        return Icons.work;
      case "Особисте":
        return Icons.person;
      case "Навчання":
        return Icons.school;
      case "Покупки":
        return Icons.shopping_cart;
      default:
        return Icons.task;
    }
  }

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Мої завдання'),
          centerTitle: true,
          actions: [
            Switch(
              value: isDark,
              onChanged: (value) {
                setState(() => isDark = value);
                _saveTheme();
              },
            )
          ],
        ),
        body: tasks.isEmpty
            ? const Center(child: Text("Немає завдань"))
            : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];

                  return Card(
                    child: ListTile(
                      onTap: () => _openTask(task),
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          setState(() => task.isCompleted = value!);
                          _saveTasks();
                        },
                      ),
                      title: Text(task.title),
                      subtitle:
                          Text("Створено: ${_formatDate(task.createdAt)}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getCategoryIcon(task.category)),
                          IconButton(
                            icon: const Icon(Icons.delete),
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
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
