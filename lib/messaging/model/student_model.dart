class StudentModel {
  final String adm_no;
  final String st_name;
  final String feecategory;
  final String st_class;
  final String st_section;
  final bool isAppInstalled;
  int noOfUnreadMessages;

  StudentModel(
      {required this.adm_no,
      required this.st_name,
      required this.feecategory,
      required this.st_class,
      required this.st_section,
      required this.isAppInstalled,
      required this.noOfUnreadMessages});

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      adm_no: json['adm_no'],
      st_name: json['st_name'],
      feecategory: json['feecategory'],
      st_class: json['st_class'],
      st_section: json['st_section'],
      isAppInstalled: json['isAppInstalled'] == 'Y' ? true : false,
      noOfUnreadMessages: json['noOfUnreadMessages'],
    );
  }
}
