import 'dart:async';
import 'dart:convert';
import 'package:cskmemp/app_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var _isLoading = false;

  void loginFailed() {
    EasyLoading.showError('Login Failed');
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('Login failed'),
    //   ),
    // );
    setState(() => _isLoading = false);
  }

  Future<void> login() async {
    FocusScope.of(context).unfocus();
    // Make a POST request to the server
    //print("Login function called");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var deviceToken = prefs.getString('deviceToken');
    //print("deviceToken = $deviceToken");
    setState(() => _isLoading = true);
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmemp/checkLogin.php'),
      body: {
        'username': _usernameController.text,
        'password': _passwordController.text,
        'deviceToken': deviceToken,
      },
    );
    //print("response = ${response.body}");
    // Check the response status code
    if (response.statusCode == 200) {
      EasyLoading.showSuccess('Login Successful');
      // The login was successful
      var data = jsonDecode(response.body);
      // Save the login state permanently
      var status = data['status'];
      if (status == 'valid') {
        var userNo = data['userNo'];
        var ename = data['ename'];
        var userid = data['userid'];
        var password1 = data['password1'];
        var othersPendingTasks = data['othersPendingTasks'];
        var classTeacher = data['classTeacher'];
        var isOffSupdt = data['isOffSupdt'];
        var isTptIncharge = data['isTptIncharge'];
        var isHostelIncharge = data['isHostelIncharge'];
        var isAccountant = data['isAccountant'];

        prefs.setInt('userNo', userNo);
        prefs.setString('ename', ename);
        prefs.setString('userid', userid);
        prefs.setString('password1', password1);
        prefs.setBool('loggedInState', true);
        prefs.setBool('othersPendingTasks', othersPendingTasks);
        prefs.setBool('classTeacher', classTeacher);
        prefs.setBool('isOffSupdt', isOffSupdt);
        prefs.setBool('isTptIncharge', isTptIncharge);
        prefs.setBool('isHostelIncharge', isHostelIncharge);
        prefs.setBool('isAccountant', isAccountant);

        await AppConfig.setGlobalVariables();

        // Navigate to the home screen
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      } else {
        // The login was unsuccessful
        loginFailed();
      }
      //Navigator.pushNamed(context, '/home');
    } else {
      // The login was unsuccessful
      loginFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSKM Emp Login'),
      ),
      body: Container(
        decoration: AppConfig.boxDecoration(),
        child: Center(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/cskm-logo.png',
                    height: 100,
                  ),
                  TextField(
                    controller: _usernameController,
                    style: AppConfig.normalWhite20(),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: AppConfig.normaYellow20(),
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    style: AppConfig.normalWhite20(),
                    decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: AppConfig.normaYellow20()),
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16.0)),
                    icon: _isLoading
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.login),
                    label: const Text('LOGIN'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
