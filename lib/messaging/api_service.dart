import 'dart:convert';
import 'package:cskmemp/messaging/model/message_model.dart';
import 'package:http/http.dart' as http;
import 'package:cskmemp/messaging/model/student_model.dart';
import 'package:cskmemp/app_config.dart';

class ApiService {
  static const String baseUrl = 'https://www.cskm.com/schoolexpert/cskmemp';

  Future<List<StudentModel>> getStudents(String userNo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_students.php'),
      body: {
        'userNo': userNo,
        'secretKey': AppConfig.secreetKey,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      //print("response= $jsonData");
      // return List<StudentModel>.from(
      //     //employees = List<Map<String, dynamic>>.from(data['employees']);
      //     jsonData['students'].map((json) => StudentModel.fromJson(json)));
      var studentList = List<StudentModel>.from(
          jsonData['students'].map((json) => StudentModel.fromJson(json)));

      studentList.sort((a, b) {
        // Sort by noOfUnreadMessages in descending order
        var result = b.noOfUnreadMessages.compareTo(a.noOfUnreadMessages);
        if (result != 0) {
          return result;
        }

        // If noOfUnreadMessages are equal, sort by st_name in ascending order
        return a.st_name.compareTo(b.st_name);
      });

      return studentList;
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<void> sendMessage(String fromNo, String toNo, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send_message.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'userNo': fromNo.toString(),
        'adm_no': toNo.toString(),
        'message': message,
      },
    );
    //print("response= ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to send message');
    }
  }

  Future<List<MessageModel>> getMessages(String fromNo, String toNo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_messages.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'userNo': fromNo.toString(),
        'adm_no': toNo.toString(),
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      //print("response= $jsonData");
      List<MessageModel> messages = [];

      if (jsonData.containsKey('messages')) {
        List<dynamic> messageList = jsonData['messages'];

        for (var messageData in messageList) {
          if (messageData.containsKey('msgType')) {
            String msgType = messageData['msgType'];
            if (msgType == 'S') {
              String fromNo = messageData['userno'].toString();
              String toNo = messageData['adm_no'].toString();
              String message = messageData['msg'];
              var dateTimeStr = messageData['msgDate']['date'];
              DateTime dateTime = DateTime.parse(dateTimeStr);

              MessageModel messageModel = MessageModel(
                  fromNo: fromNo,
                  toNo: toNo,
                  message: message,
                  dateTime: dateTime);
              messages.add(messageModel);
            } else if (msgType == 'P') {
              String fromNo = messageData['adm_no'].toString();
              String toNo = messageData['userno'].toString();
              String message = messageData['msg'];
              var dateTimeStr = messageData['msgDate']['date'];
              DateTime dateTime = DateTime.parse(dateTimeStr);

              MessageModel messageModel = MessageModel(
                fromNo: fromNo,
                toNo: toNo,
                message: message,
                dateTime: dateTime,
              );

              messages.add(messageModel);
            }
          }
        }
      }
      //print(messages);
      return messages;
    } else {
      throw Exception('Failed to load messages');
    }
  }
}
