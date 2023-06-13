import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cskmemp/app_config.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

StreamController<bool> streamController = StreamController<bool>.broadcast();

class OthersTask {
  final int taskId;
  final String date;
  final String description;
  final String assignedTo;
  bool completed;

  OthersTask({
    required this.taskId,
    required this.date,
    required this.description,
    required this.assignedTo,
    this.completed = false,
  });
}

class TaskListScreenOthers extends StatefulWidget {
  const TaskListScreenOthers(
      {super.key, required this.stream, required this.taskType});
  final Stream<bool> stream;
  final String taskType;

  @override
  _TaskListScreenStateOthers createState() => _TaskListScreenStateOthers();
}

class _TaskListScreenStateOthers extends State<TaskListScreenOthers> {
  List<OthersTask> tasks = [];
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
        'taskType': 'Others',
      },
    );
    //print("response = ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print("data = $data");
      if (this.mounted) {
        setState(() {
          tasks = List<OthersTask>.from(data['tasks'].map((task) => OthersTask(
                taskId: task['taskId'],
                date: task['date'],
                description: task['description'],
                assignedTo: task['assignedBy'],
              )));
        });
      }
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

  Future<void> saveTaskCompletion(OthersTask task) async {
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
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task Completed.'),
        ),
      );
      //EasyLoading.showSuccess('Task Completed.');
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
            leading: _saving
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
                  ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description),
                Row(
                  children: [
                    const Text(
                      'Assigned to: ',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        task.assignedTo,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color.fromARGB(255, 122, 0, 0),
                        ),
                      ),
                    ),
                  ],
                )
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
