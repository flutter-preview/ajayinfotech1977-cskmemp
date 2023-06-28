import 'package:cskmemp/messaging/broadcast_form.dart';
import 'package:flutter/material.dart';
import 'package:cskmemp/messaging/chat_screen.dart';
//import 'package:cskmemp/messaging/broadcastscreen.dart';

class MessageTabbedScreen extends StatefulWidget {
  @override
  _MessageTabbedScreenState createState() => _MessageTabbedScreenState();
}

class _MessageTabbedScreenState extends State<MessageTabbedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
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
        title: Text('CSKM Smart Messaging'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Students'),
            Tab(text: 'Broadcast'),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return MessageForm(
      //             //onSave: (Message) {
      //             //Messages.add(Message);
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
              child: Center(
                child: StudentListScreen(),
              ),
            ),
          ),
          // Screen 2 content

          BroadcastForm(),
        ],
      ),
    );
  }
}
