import 'dart:async';
import 'package:cskmemp/app_config.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';

//StreamController<bool> streamController = StreamController<bool>.broadcast();

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

class CompletedTasks extends StatefulWidget {
  const CompletedTasks({super.key});

  @override
  _CompletedTasksState createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks> {
  String userNo = "";
  List<Task> tasks = [];

  @override
  void initState() {
    fetchData();
    super.initState();

    // widget.stream.listen((event) {
    //   fetchData();
    // });
  }

  Future<void> fetchData() async {
    EasyLoading.show(status: 'Loading...');
    var userNo = await AppConfig().getUserNo().then((String result) => result);
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/fetchTasks.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'userNo': userNo,
        'taskType': 'Completed',
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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('Error Fetching Tasks. Please Retry Later!'),
      //   ),
      // );
      EasyLoading.showError('Error Fetching Tasks. Please Retry Later!');
    }
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Completed Tasks'),
      ),
      body: Center(
        child: Container(
          decoration: AppConfig.boxDecoration(),
          height: double.infinity,
          padding: const EdgeInsets.all(16.0),

          //Tasks assigned to user of the app
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5.0,
                child: ListTile(
                  leading: null,
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
          ),
        ),
      ),
    );
  }
}
