import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cskmemp/app_config.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

StreamController<bool> streamController = StreamController<bool>.broadcast();

class Task {
  final int taskId;
  final String date;
  final String description;
  final String assignedBy;
  bool completed;

  Task({
    required this.taskId,
    required this.date,
    required this.description,
    required this.assignedBy,
    this.completed = false,
  });
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen(
      {super.key, required this.stream, required this.taskType});
  final Stream<bool> stream;
  final String taskType;

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  bool _saving = false;
  @override
  void initState() {
    fetchData();
    super.initState();
    widget.stream.listen((event) {
      fetchData();
    });
  }

  @override
  void dispose() {
    tasks.clear();
    super.dispose();
  }

  Future<void> fetchData() async {
    EasyLoading.show(status: 'Loading...');

    var userNo = await AppConfig().getUserNo().then((String result) => result);
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/fetchTasks.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'userNo': userNo,
        'taskType': 'My',
      },
    );
    //print("response = ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print("data = $data");
      setState(() {
        tasks = List<Task>.from(data['tasks'].map((task) => Task(
              taskId: task['taskId'],
              date: task['date'],
              description: task['description'],
              assignedBy: task['assignedBy'],
            )));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Fetching Tasks. Please Retry Later!'),
        ),
      );
      //EasyLoading.showError('Error Fetching Tasks. Please Retry Later!');
    }
    EasyLoading.dismiss();
  }

  Future<void> saveTaskCompletion(Task task) async {
    setState(() {
      _saving = true;
    });
    final response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/completeTask.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'taskId': task.taskId.toString(),
      }, // Replace 'taskId' with the actual parameter name
    );
    //print(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task Completed.'),
        ),
      );
      //EasyLoading.showSuccess('Task Completed');
      fetchData(); // Reload the data after completing the task
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Saving Task Status. Please Retry Later!'),
        ),
      );
      //EasyLoading.showError('Error Saving Task Status. Please Retry Later!');
    }
    setState(() {
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5.0,
          child: ListTile(
            leading:
                //if the task is assigned by himself only then show check box
                (task.assignedBy == "Yourself")

                    //if the checkbox is pressed this will become true and hide the checkbox
                    ? _saving
                        ? const CircularProgressIndicator(
                            color: Colors.blue,
                            strokeWidth: 3,
                          )
                        : Checkbox(
                            value: task.completed,
                            onChanged: (value) {
                              setState(() {
                                task.completed = value!;
                              });
                              saveTaskCompletion(task);
                            },
                          )
                    : null,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description),
                Text(
                  'Assigned by: ${task.assignedBy}',
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            trailing: SizedBox(
              width: 65,
              child: Text(
                task.date,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}
