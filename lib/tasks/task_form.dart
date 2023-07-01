import 'dart:async';

import 'package:cskmemp/app_config.dart';
import 'package:cskmemp/tasks/task_display_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

StreamController<bool> streamController = StreamController<bool>.broadcast();

class TaskForm extends StatefulWidget {
  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> employees = [];
  String userNo = "";

  final TextEditingController _taskController = TextEditingController();
  String? userNoSelected;
  bool _saving = false;

  Future<void> fetchEmployees() async {
    await AppConfig().getUserNo().then((String result) {
      userNo = result;
      userNoSelected = userNo;
    });

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
        child: Container(
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
    return Container(
      height: double.infinity,
      //padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          taskFormWidget(), //form to display whose code is in the same file.
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Your Pending Tasks',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 236, 244, 250)),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            //Tasks assigned to user of the app
            child: TaskListScreen(
              stream: streamController.stream,
              taskType: 'My',
            ),
          ),
        ],
      ),
    );
  }

  Form taskFormWidget() {
    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              style: AppConfig.normalWhite(),
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Task',
                labelStyle: AppConfig.normaYellow(),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a task';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              itemHeight: null,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Assign To',
                labelStyle: AppConfig.normaYellow(),
              ),
              items: dropDownItems,
              value: userNo,
              onChanged: (value) {
                setState(() {
                  userNoSelected = value as String;
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
          const SizedBox(width: 8.0),
          IconButton(
            icon: _saving
                ? Container(
                    width: 24,
                    height: 24,
                    padding: const EdgeInsets.all(2.0),
                    child: const CircularProgressIndicator(
                      color: Color.fromARGB(255, 236, 244, 250),
                      strokeWidth: 3,
                    ),
                  )
                : const Icon(Icons.save,
                    color: Color.fromARGB(255, 236, 244, 250)),
            onPressed: _saving
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      addTask();
                      //print("Saving...");
                    }
                  },
          ),
        ],
      ),
    );
  }

  void addTask() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
    });
    //print("from add task");
    var bodyData = {
      'secretKey': AppConfig.secreetKey,
      'AssignedBy': userNo,
      'userNo': userNoSelected,
      'task': _taskController.text,
    };
    //print(bodyData);
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/addTask.php'),
      body: bodyData,
    );

    //print("response = ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == "ok") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task Saved'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Problem saving task. Retry later.'),
          ),
        );
      }
      //print(data['status']);
    }
    setState(() {
      _taskController.text = "";
      streamController.add(true);
      _saving = false;
    });
  }
}
