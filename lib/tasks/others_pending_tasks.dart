import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cskmemp/app_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';

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

class OthersPendingTasksScreen extends StatelessWidget {
  const OthersPendingTasksScreen({super.key});

  @override
  Widget build(context) {
    return Container(
      //height: double.infinity,
      decoration: AppConfig.boxDecoration(),
      child: const PendingTaskForm(),
    );
  }
}

class PendingTaskForm extends StatefulWidget {
  const PendingTaskForm({super.key});
  @override
  _PendingTaskFormState createState() => _PendingTaskFormState();
}

class _PendingTaskFormState extends State<PendingTaskForm> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> employees = [];
  String userNo = "";
  List<Task> tasks = [];

  String? userNoSelected;

  Future<void> fetchEmployees() async {
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/fetchenames.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print("Response = $data");

      // print(employees);
      setState(() {
        employees = List<Map<String, dynamic>>.from(data['employees']);
      });
    }
  }

  List<DropdownMenuItem<String>> get dropDownItems {
    List<DropdownMenuItem<String>> menuItems = employees.map((employee) {
      return DropdownMenuItem<String>(
        value: employee['userno'].toString(),
        child: //Text(employee['ename']),
            Container(
          //width: double.infinity,
          //height: 10,
          margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          decoration:
              AppConfig.boxDecoration(), // Set the background color here
          child: Text(
            employee['ename'],
            style: TextStyle(
              color: Colors.white, // Set the text color here
            ),
          ),
        ),
      );
    }).toList();

    return menuItems;
  }

  @override
  void initState() {
    fetchEmployees();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(width: 16.0),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    itemHeight: null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Show Pending Tasks of:',
                      labelStyle: AppConfig.normaYellow(),
                    ),
                    items: dropDownItems,
                    //value: userNo,
                    onChanged: (value) {
                      setState(() {
                        userNoSelected = value as String;
                        fetchPendingTasks();
                        //print("userNoSelected = $userNoSelected");
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an employee';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: showPendingTasks(),
          ),
        ],
      ),
    );
  }

  void fetchPendingTasks() async {
    setState(() {
      EasyLoading.show(status: 'loading...');
    });
    //print("from add task");
    var bodyData = {
      'secretKey': AppConfig.secreetKey,
      'userNo': userNoSelected,
      'taskType': 'Pending',
    };
    //print(bodyData);
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/fetchTasks.php'),
      body: bodyData,
    );

    //print("response = ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print(data);
      setState(() {
        tasks = List<Task>.from(data['tasks'].map((task) => Task(
              taskId: task['taskId'],
              date: task['date'],
              description: task['description'],
              assignedBy: task['assignedBy'],
            )));
      });
    }
    setState(() {
      EasyLoading.dismiss();
    });
  }

  ListView showPendingTasks() {
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
    );
  }
}
