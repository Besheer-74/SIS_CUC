class StudentModel {
  final String id;
  final String studentCode;
  final String applicationId;
  final int? facultyId;
  final int? majorId;
  final int currentSemester;
  final int maxCreditHours;
  final String status;
  final DateTime createdAt;

  StudentModel({
    required this.id,
    required this.studentCode,
    required this.applicationId,
    this.facultyId,
    this.majorId,
    required this.currentSemester,
    required this.maxCreditHours,
    required this.status,
    required this.createdAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      studentCode: json['student_code'],
      applicationId: json['application_id'],
      facultyId: json['faculty_id'],
      majorId: json['major_id'],
      currentSemester: json['current_semester'] ?? 1,
      maxCreditHours: json['max_credit_hours'] ?? 18,
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  StudentModel copyWith({
    int? currentSemester,
    int? maxCreditHours,
  }) {
    return StudentModel(
      id: id,
      studentCode: studentCode,
      applicationId: applicationId,
      facultyId: facultyId,
      majorId: majorId,
      currentSemester: currentSemester ?? this.currentSemester,
      maxCreditHours: maxCreditHours ?? this.maxCreditHours,
      status: status,
      createdAt: createdAt,
    );
  }
}
