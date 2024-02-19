import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      home: TodoApp(),
    );
  }
}

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List<Task> tasks = [];
  int _nextTaskId = 1;

  void _addTask() async {
    final Task? newTask = await showDialog<Task>(
      context: context,
      builder: (context) => TaskDialog(),
    );

    if (newTask != null) {
      newTask.id = _nextTaskId++;
      setState(() {
        tasks.add(newTask);
      });
    }
  }

  void _editTask(Task task) async {
    final Task? editedTask = await showDialog<Task>(
      context: context,
      builder: (context) => TaskDialog(task: task),
    );

    if (editedTask != null) {
      setState(() {
        tasks[tasks.indexWhere((t) => t.id == task.id)] = editedTask;
      });
    }
  }

  void _deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });
  }

  Future<void> _selectDueDate(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      controller.text = pickedDate.toLocal().toString().split(' ')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5.0,
            child: ListTile(
              tileColor: Colors.grey[200],
              title: Text(
                task.name,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              subtitle: Text(
                "Due Date : ${task.dueDate}",
                style: TextStyle(color: Colors.grey),
              ),
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (value) {
                  setState(() {
                    task.isCompleted = value!;
                  });
                },
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined),
                    color: Colors.blue,
                    onPressed: () {
                      _editTask(task);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outlined),
                    color: Colors.red,
                    onPressed: () {
                      _deleteTask(task);
                    },
                  ),
                ],
              ),
              onTap: () {
                _editTask(task);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _addTask();
        },
        label: const Text("Add Task"),
        icon: const Icon(Icons.add),
        elevation: 10,
        hoverColor: Colors.blueAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class Task {
  int? id;
  String name;
  bool isCompleted;
  String dueDate;

  Task(
      {this.id,
      required this.name,
      required this.isCompleted,
      required this.dueDate});
}

class TaskDialog extends StatefulWidget {
  final Task? task;

  const TaskDialog({Key? key, this.task}) : super(key: key);

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController _nameController;
  late TextEditingController _dueDateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task?.name ?? '');
    _dueDateController =
        TextEditingController(text: widget.task?.dueDate ?? '');
  }

  Future<void> _selectDueDate(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      controller.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      content: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Task Name'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dueDateController,
                  decoration: const InputDecoration(labelText: 'Due Date'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  _selectDueDate(_dueDateController);
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final dueDate = _dueDateController.text.trim();

            if (name.isNotEmpty) {
              final task =
                  Task(name: name, isCompleted: false, dueDate: dueDate);
              Navigator.pop(context, task);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
