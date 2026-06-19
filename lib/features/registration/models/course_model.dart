class RegistrationCourseModel {
  const RegistrationCourseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.creditHours,
  });

  final int id;
  final String code;
  final String name;
  final int creditHours;

  factory RegistrationCourseModel.fromJson(Map<String, dynamic> json) {
    return RegistrationCourseModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      code: json['course_code']?.toString() ?? '-',
      name: json['course_name']?.toString() ?? '-',
      creditHours: int.tryParse(json['credit_hours']?.toString() ?? '') ?? 0,
    );
  }
}

class AvailableRegistrationCourse {
  const AvailableRegistrationCourse({
    required this.assignmentId,
    required this.studentId,
    required this.course,
    required this.semester,
  });

  final String assignmentId;
  final String studentId;
  final RegistrationCourseModel course;
  final String semester;

  factory AvailableRegistrationCourse.fromJson(Map<String, dynamic> json) {
    final courseJson =
        (json['courses'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    return AvailableRegistrationCourse(
      assignmentId: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      course: RegistrationCourseModel.fromJson(courseJson),
      semester: json['semester']?.toString() ?? '',
    );
  }
}
