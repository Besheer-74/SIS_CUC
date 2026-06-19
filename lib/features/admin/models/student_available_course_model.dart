class StudentAvailableCourseModel {
  final String id;
  final String studentId;
  final int courseId;
  final int semester;
  final bool isEnabled;
  final DateTime createdAt;

  StudentAvailableCourseModel({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.semester,
    required this.isEnabled,
    required this.createdAt,
  });

  factory StudentAvailableCourseModel.fromJson(Map<String, dynamic> json) {
    return StudentAvailableCourseModel(
      id: json['id'],
      studentId: json['student_id'],
      courseId: json['course_id'],
      semester: json['semester'] ?? 1,
      isEnabled: json['is_enabled'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
