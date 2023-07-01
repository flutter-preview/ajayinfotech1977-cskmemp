import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cskmemp/app_config.dart';

class BroadcastForm extends StatefulWidget {
  @override
  _BroadcastFormState createState() => _BroadcastFormState();
}

class _BroadcastFormState extends State<BroadcastForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> classes = [];
  String selectedClass = '';
  String selectedFeeCategory = 'All';
  String selectedGender = 'All';
  String message = '';
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      // Prepare data to send
      Map<String, dynamic> postData = {
        'secretKey': AppConfig.secreetKey,
        'userNo': AppConfig.globalUserNo, // Replace with the actual user number
      };
      final String apiUrl =
          'https://www.cskm.com/schoolexpert/cskmemp/fetch_classes.php';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: postData,
      );
      final data = await json.decode(response.body);
      //print("data is $data");
      setState(() {
        classes = List<String>.from(data['classes']);
        selectedClass = classes[0];
        //print("classes is $classes");
      });
    } catch (e) {
      print('Error fetching classes: $e');
    }
  }

  Future<void> sendMessage() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSending = true;
        //close keypad
        FocusScope.of(context).unfocus();
      });

      // Prepare data to send
      Map<String, dynamic> postData = {
        'class': selectedClass,
        'feeCategory': selectedFeeCategory,
        'gender': selectedGender,
        'message': message,
        'userNo': AppConfig.globalUserNo,
        'secretKey': AppConfig.secreetKey,
      };

      try {
        // Send data to the server
        final response = await http.post(
          Uri.parse(
              'https://www.cskm.com/schoolexpert/cskmemp/send_broadcast.php'),
          body: postData,
        );

        if (response.statusCode == 200) {
          setState(() {
            message = '';
            isSending = false;
          });
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Success'),
              content: Text('Messages Sent'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    //navigate to /messagetabbedscreen and remove this screen from the stack
                    Navigator.of(context)
                        .pushReplacementNamed('/messagetabbedscreen');
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          throw Exception('Failed to send message');
        }
      } catch (e) {
        print('Error sending message: $e');
        setState(() {
          isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: selectedClass,
                onChanged: (value) {
                  setState(() {
                    selectedClass = value!;
                  });
                },
                items: classes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Class and Section',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a class';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: selectedFeeCategory,
                onChanged: (value) {
                  setState(() {
                    selectedFeeCategory = value!;
                  });
                },
                items: ['All', 'Boarder', 'Day Boarder', 'Staff Child']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Category',
                ),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
                items: ['All', 'Boys', 'Girls'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Gender',
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    message = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Message',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: isSending ? null : sendMessage,
                child: isSending ? CircularProgressIndicator() : Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
