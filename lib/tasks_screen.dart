import 'package:cskmemp/task_form.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cskmemp/app_config.dart';
//import 'package:flutter_easyloading/flutter_easyloading.dart';
//EasyLoading.show(status: 'Loading...');
//EasyLoading.dismiss();

enum MenuItem {
  pendingTasks,
  completedTasks,
  othersPendingTasks,
}

StreamController<bool> streamController = StreamController<bool>.broadcast();

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(context) {
    //EasyLoading.show(status: 'Loading...');
    return StreamBuilder<Object>(
        stream: Stream.fromFuture(AppConfig().isOthersPendingTasksAllowed()),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Smart Task Management'),
              actions: <Widget>[
                PopupMenuButton<MenuItem>(
                    initialValue: MenuItem.pendingTasks,
                    onSelected: (MenuItem item) {
                      //print(item.name);
                      // Navigator.pushNamedAndRemoveUntil(
                      //     context, '/login', (_) => false);
                      if (item.name == "pendingTasks") {
                        Navigator.pushNamed(context, '/tasks');
                      } else if (item.name == "completedTasks") {
                        Navigator.pushNamed(context, '/completedtasks');
                      } else if (item.name == "othersPendingTasks" &&
                          snapshot.data == true) {
                        Navigator.pushNamed(context, '/othersPendingTasks');
                      }
                    },
                    itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: MenuItem.pendingTasks,
                            child: Text('Pending Tasks'),
                          ),
                          const PopupMenuItem(
                            value: MenuItem.completedTasks,
                            child: Text('Completed Tasks'),
                          ),
                          if (snapshot.data == true)
                            const PopupMenuItem(
                              value: MenuItem.othersPendingTasks,
                              child: Text('Others Pending Tasks'),
                            )
                        ])
              ],
            ),
            body: Container(
              height: double.infinity,
              decoration: AppConfig.boxDecoration(),
              child: Center(
                child: TaskForm(),
              ),
            ),
          );
        });
  }
}
