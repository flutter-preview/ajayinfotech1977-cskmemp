import 'package:cskmemp/tasks/completed_tasks.dart';
import 'package:cskmemp/tasks/others_pending_tasks.dart';
import 'package:cskmemp/tasks/task_form.dart';
import 'package:flutter/material.dart';
import 'package:cskmemp/app_config.dart';
import 'package:cskmemp/tasks/task_list_other.dart';

class TaskTabbedScreen extends StatefulWidget {
  @override
  _TaskTabbedScreenState createState() => _TaskTabbedScreenState();
}

class _TaskTabbedScreenState extends State<TaskTabbedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  dynamic totalTabs = 3;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    totalTabs = ModalRoute.of(context)!.settings.arguments as int;
    //print("From didChange totalTabs = $totalTabs");
    _tabController = TabController(
      length: totalTabs,
      vsync: this,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Task Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Assigned'),
            Tab(text: 'Completed'),
            if (totalTabs == 4) Tab(text: 'Others'),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return TaskForm(
      //             //onSave: (task) {
      //             //tasks.add(task);
      //             //},
      //             );
      //       },
      //     );
      //   },
      //   child: Icon(Icons.add),
      // ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Screen 1 content
          Center(
            child: Container(
              height: double.infinity,
              decoration: AppConfig.boxDecoration(),
              child: Center(
                child: TaskForm(),
              ),
            ),
          ),
          // Screen 2 content
          Center(
            child: Container(
              height: double.infinity,
              decoration: AppConfig.boxDecoration(),
              child: Center(
                child: TaskListOther(),
              ),
            ),
          ),
          // Screen 3 content
          Center(child: CompletedTasks()),
          //Screen 4 content
          if (totalTabs == 4) Center(child: OthersPendingTasksScreen()),
        ],
      ),
    );
  }
}
