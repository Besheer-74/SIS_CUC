class CourseModel {
  final int id;
  final String code;
  final String name;
  final int creditHours;
  final int facultyId;
  final int majorId;
  final int semesterNumber;
  final bool isActive;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.creditHours,
    required this.facultyId,
    required this.majorId,
    required this.semesterNumber,
    required this.isActive,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      code: json['course_code'],
      name: json['course_name'],
      creditHours: json['credit_hours'] ?? 0,
      facultyId: json['faculty_id'],
      majorId: json['major_id'],
      semesterNumber: json['semester_no'] ?? 1,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
