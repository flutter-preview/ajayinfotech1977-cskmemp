class MessageModel {
  final String fromNo;
  final String toNo;
  final String message;
  final DateTime dateTime;

  MessageModel({
    required this.fromNo,
    required this.toNo,
    required this.message,
    required this.dateTime,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      fromNo: json['fromNo'],
      toNo: json['toNo'],
      message: json['message'],
      dateTime: json['dateTime'],
    );
  }
}
