import 'package:cskmemp/app_config.dart';
import 'package:flutter/material.dart';

class HomeScreenButtons extends StatelessWidget {
  const HomeScreenButtons({super.key});

  void openTasks(context) {
    Navigator.pushNamed(context, '/tasks');
    //print("On Tap clicked from open Tasks");
  }

  void openMessages(context) {
    //print("On Tap clicked from messages");
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
        ButtonWidget(
          buttonText: 'Messages',
          icon: Icons.messenger,
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
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(0, 0, 0, 0)),
            label: Text(
              buttonText,
              //style: AppConfig.normalWhite20(),
            ),
            icon: Icon(icon),
            onPressed: () => onTap(context),
          ),
        ),
      ),
    );
  }
}
