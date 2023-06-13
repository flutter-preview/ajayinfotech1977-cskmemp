import 'dart:async';
import 'package:cskmemp/task_display_screen_others.dart';
import 'package:flutter/material.dart';

StreamController<bool> streamController = StreamController<bool>.broadcast();

class TaskListOther extends StatefulWidget {
  @override
  _TaskListOtherState createState() => _TaskListOtherState();
}

class _TaskListOtherState extends State<TaskListOther> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      //padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          const Text(
            'Your Assigned Pending Tasks',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 236, 244, 250)),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            //Tasks assigned by the user to others
            child: TaskListScreenOthers(
              stream: streamController.stream,
              taskType: 'Other',
            ),
          ),
        ],
      ),
    );
  }
}
