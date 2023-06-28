import 'dart:async';
import 'package:cskmemp/tasks/completed_tasks.dart';
import 'package:cskmemp/tasks/others_pending_tasks.dart';
import 'package:cskmemp/tasks/task_tabbed_screen.dart';
import 'package:cskmemp/tasks/tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cskmemp/home_screen.dart';
import 'package:cskmemp/login_screen.dart';
import 'package:cskmemp/app_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cskmemp/firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// TODO: Add stream controller
import 'package:rxdart/rxdart.dart';

import 'messaging/chat_screen.dart';
import 'messaging/message_tabbed_screen.dart';

// used to pass messages from event handler to the UI
final _messageStreamController = BehaviorSubject<RemoteMessage>();
//const kDebugMode = true;

//Notification configuration
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// TODO: Define the background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  String title = message.notification?.title as String;
  String msg = message.notification?.body as String;
  showNotification(title, msg);

  // if (kDebugMode) {
  //   print("Handling a background message: ${message.messageId}");
  //   print('Message data: ${message.data}');
  //   print('Message notification: ${message.notification?.title}');
  //   print('Message notification: ${message.notification?.body}');
  // }
}

void main() {
  initializeFirebase();
  AppConfig.setGlobalVariables();
  runApp(MyApp());
}

void initializeFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // TODO: Request permission
  final messaging = FirebaseMessaging.instance;

  //final settings =
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  //print('Permission granted: ${settings.authorizationStatus}');

  // TODO: Register with FCM
  // It requests a registration token for sending messages to users from your App server or other trusted server environment.
  String? token = await messaging.getToken() as String;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('deviceToken', token);
  //print('Registration Token=$token');

  // TODO: Set up foreground message handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String title = message.notification?.title as String;
    String msg = message.notification?.body as String;
    /**********For Reading the data and using it uncomment below lines */
    // var data = message.data;
    // if (data.isNotEmpty) {
    //   print(data);
    //   if (data.containsKey('msgtype')) {
    //     String dataValue = message.data['msgtype'];
    //     // Process the data as needed
    //     print('Received data from PHP: $dataValue');
    //   }
    // }

    showNotification(title, msg);
    // if (kDebugMode) {
    //   print('Handling a foreground message: ${message.messageId}');
    //   print('Message data: ${message.data}');
    //   print('Message notification: ${message.notification?.title}');
    //   print('Message notification: ${message.notification?.body}');
    // }

    _messageStreamController.sink.add(message);
  });

  //TODO: Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize the FlutterLocalNotificationsPlugin
  await initializeNotifications();
}

//intialize notifications
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Replace with your app icon name

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
          onDidReceiveLocalNotification:
              (int id, String? title, String? body, String? payload) async {});

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {});
}

//show notification
Future<void> showNotification(String title, String message) async {
  String longdata = message;

  BigTextStyleInformation bigTextStyleInformation =
      BigTextStyleInformation(longdata); //multi-line show style

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'tasks', // Replace with your own channel ID
    'Smart Task Management', // Replace with your own channel name
    channelDescription:
        'Show all pending tasks to the user', // Replace with your own channel description
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    enableVibration: true,
    styleInformation: bigTextStyleInformation,
    largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
  );
  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: DarwinNotificationDetails(),
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    message,
    platformChannelSpecifics,
    payload: '/home', // The route to navigate when notification is clicked
  );
}

/// *****************************************************************
/// Actual Code for displaying the first
/// screen of the app starts from here
/// *****************************************************************

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /*************************************************************
   * Code for autoupdate of android app
   * Done on 05-June-2023
   * ***********************************************************/
  AppUpdateInfo? _updateInfo;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  //bool _flexibleUpdateAvailable = false;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
    }).catchError((e) {
      showSnack(e.toString());
    });
  }

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }
  /*************Auto Update Code Completed *****************************/

  Future<bool> checkLoginState() async {
    //Call checkForUpdate() to check and return if an update is available uncomment below line to activate this feature
    //checkForUpdate();
    //if an update is available, immediately update it. uncomment below code
    if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
      //EasyLoading.dismiss();
      InAppUpdate.performImmediateUpdate()
          .catchError((e) => showSnack(e.toString()));
    }
    ;
    /******Auto update calling complete***************/
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('userid')) {
      var userid = prefs.getString('userid');
      var password1 = prefs.getString('password1');
      var appConfig = AppConfig();
      var logginStateValue =
          appConfig.checkLogin(userid: userid, password1: password1);
      return logginStateValue;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSKM EMP',
      home: StreamBuilder(
        stream: Stream.fromFuture(checkLoginState()),
        initialData: checkLoginState,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //custom config easyloading
            //AppConfig.configLoading();
            //EasyLoading.show(status: "Loading...");
            return const SpalshScreen();
          }
          if (snapshot.data == true) {
            //EasyLoading.dismiss();
            return const HomeScreen();
          } else {
            //EasyLoading.dismiss();
            return const LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/tasks': (context) => const TasksScreen(),
        '/completedtasks': (context) => const CompletedTasks(),
        '/othersPendingTasks': (context) => const OthersPendingTasksScreen(),
        '/tasktabbedscreen': (context) => TaskTabbedScreen(),
        '/chatscreen': (context) => StudentListScreen(),
        '/messagetabbedscreen': (context) => MessageTabbedScreen(),
      },
      builder: EasyLoading.init(),
    );
  }
}

class SpalshScreen extends StatefulWidget {
  const SpalshScreen({super.key});

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    return const SplashScreenWidget();
  }
}

class SplashScreenWidget extends StatelessWidget {
  const SplashScreenWidget({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      body: Container(
        decoration: AppConfig.boxDecoration(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/cskm-logo.png',
                width: 200,
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                "CSKM Public School",
                style: AppConfig.boldWhite30(),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Employee Login",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SpinKitFadingCircle(
                color: const Color.fromARGB(255, 250, 251, 253),
                size: 50.0,
              ),
              SizedBox(height: 16.0),
              Text('Loading...'),
            ],
          ),
        ),
      ),
    );
  }
}
