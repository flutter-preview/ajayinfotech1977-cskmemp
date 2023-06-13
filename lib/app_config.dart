import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AppConfig {
  /*below is a secretkey encrypted key which will go with each post 
  request so that nobody else can view the php file response except 
  of this app. Please dont tamper ot change this value. Its equivalent 
  decrypted text should be "ILove@Flutter_dart" which will be checked by php
  file before fetching any kind of data.
  */
  static String secreetKey = "WhzWoMoZQO2pgmw6h6So0j0b";

  static BoxDecoration boxDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.purple,
          Colors.blue,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  static TextStyle boldWhite30() {
    return const TextStyle(
      fontSize: 30,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle normalWhite15() {
    return const TextStyle(
      fontSize: 15,
      color: Colors.white,
    );
  }

  static TextStyle normalWhite20() {
    return const TextStyle(
      fontSize: 20,
      color: Colors.white,
    );
  }

  static TextStyle normalWhite() {
    return const TextStyle(
      color: Colors.white,
    );
  }

  static TextStyle normaYellow20() {
    return const TextStyle(
      fontSize: 20,
      color: Color.fromARGB(255, 248, 227, 5),
    );
  }

  static TextStyle normaYellow() {
    return const TextStyle(
      color: Color.fromARGB(255, 248, 227, 5),
    );
  }

  Future<bool> checkLogin({
    @required userid,
    @required password1,
  }) async {
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/checkLogin.php'),
      body: {
        'username': userid,
        'password': password1,
        'encrypted': 'Yes',
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var status = data['status'];
      if (status == 'valid') {
        var userNo = data['userNo'];
        var ename = data['ename'];
        var othersPendingTasks = data['othersPendingTasks'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('userNo', userNo);
        prefs.setString('ename', ename);
        prefs.setBool('othersPendingTasks', othersPendingTasks);

        // Navigate to the home screen
        return Future.value(true);
      } else {
        // The login was unsuccessful
        logout();
        return Future.value(false);
      }
    } else {
      // The login was unsuccessful
      logout();
      return Future.value(false);
    }
  }

  Future<String> getUserNo() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userNo')) {
      var userNo = prefs.getInt('userNo').toString();
      //print("From getUserNo userNo= $userNo");
      return userNo;
    } else {
      return "";
    }
  }

  Future<bool> isOthersPendingTasksAllowed() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('othersPendingTasks')) {
      bool othersPendingTasks = prefs.getBool('othersPendingTasks') as bool;
      //print("From getUserNo userNo= $userNo");
      return Future.value(othersPendingTasks);
    } else {
      return Future.value(false);
    }
  }

  static Future<void> logout() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    var userNo = prefs.getInt('userNo').toString();
    await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/logout.php'),
      body: {
        'userNo': userNo,
        'secretKey': secreetKey,
      },
    );

    await prefs.remove('userid');
    await prefs.remove('password1');
    await prefs.remove('userNo');
    await prefs.remove('ename');
    await prefs.remove('loggedInState');
    await prefs.remove('othersPendingTasks');
  }

  static void configLoading() {
    EasyLoading easyLoading = EasyLoading();
    easyLoading.loadingStyle = EasyLoadingStyle.dark;
    //easyLoading.indicatorType = EasyLoadingIndicatorType.threeBounce;
    //easyLoading.maskType = EasyLoadingMaskType.black;
    //easyLoading.backgroundColor = Color.fromARGB(10, 83, 83, 83);
  }
}
