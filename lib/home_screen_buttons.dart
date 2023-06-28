import 'package:cskmemp/app_config.dart';
import 'package:flutter/material.dart';

class HomeScreenButtons extends StatefulWidget {
  const HomeScreenButtons({super.key});

  @override
  State<HomeScreenButtons> createState() => _HomeScreenButtonsState();
}

class _HomeScreenButtonsState extends State<HomeScreenButtons> {
  bool classTeacher = false;
  //code to store classTeacher in SharedPreferences to the global variable classTeacher

  //code to fetch classTeacher from SharedPreferences
  void openTasks(context) async {
    var totalTabs = 3;
    //final bool otherAllowed = await AppConfig().isOthersPendingTasksAllowed();
    //print("otherAllowed = $otherAllowed");
    if (AppConfig.globalOthersPendingTasks == true) totalTabs = 4;
    //print("totalTabs = $totalTabs");
    Navigator.pushNamed(context, '/tasktabbedscreen', arguments: totalTabs);
    //print("On Tap clicked from open Tasks");
  }

  void openMessages(context) {
    Navigator.pushNamed(context, '/messagetabbedscreen');
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        ButtonWidget(
          buttonText: 'Smart Task Management',
          icon: Icons.task_alt,
          onTap: openTasks,
        ),
        if (AppConfig.globalClassTeacher == true)
          ButtonWidget(
            buttonText: 'Class Teacher Smart Messaging',
            icon: Icons.messenger,
            onTap: openMessages,
          ),
        if (AppConfig.globalIsOffSupdt == true)
          ButtonWidget(
            buttonText: 'Office Smart Messaging',
            icon: Icons.supervisor_account,
            onTap: openMessages,
          ),
      ],
    );
  }
}

class ButtonWidget extends StatelessWidget {
  final String buttonText;
  final IconData icon;
  final Function onTap;
  const ButtonWidget({
    super.key,
    required this.buttonText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        height: 40.0,
        child: DecoratedBox(
          decoration: AppConfig.boxDecoration(),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(0, 0, 0, 0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.yellow,
                ),
                SizedBox(height: 8.0),
                Text(
                  buttonText,
                  style: AppConfig.normaYellow20(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // Text(
            //   buttonText,
            //   style: AppConfig.normalWhite15(),
            // ),
            //icon: Icon(icon, size: 40),
            onPressed: () => onTap(context),
          ),
        ),
      ),
    );
  }
}
