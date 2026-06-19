import 'course_model.dart';

class RegistrationRecordModel {
  const RegistrationRecordModel({
    required this.id,
    required this.studentId,
    required this.course,
    required this.semester,
    required this.status,
    this.section,
    this.instructor,
    this.day,
    this.time,
    this.room,
  });

  final String id;
  final String studentId;
  final RegistrationCourseModel course;
  final String semester;
  final String status;
  final String? section;
  final String? instructor;
  final String? day;
  final String? time;
  final String? room;

  factory RegistrationRecordModel.fromJson(Map<String, dynamic> json) {
    final courseJson =
        (json['courses'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    return RegistrationRecordModel(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      course: RegistrationCourseModel.fromJson(courseJson),
      semester: json['semester']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'registered',
      section: json['section']?.toString(),
      instructor: json['instructor']?.toString(),
      day: json['day']?.toString(),
      time: json['time']?.toString(),
      room: json['room']?.toString(),
    );
  }
}
