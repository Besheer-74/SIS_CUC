class CoursePrerequisiteModel {
  final int id;
  final int courseId;
  final int prerequisiteCourseId;

  CoursePrerequisiteModel({
    required this.id,
    required this.courseId,
    required this.prerequisiteCourseId,
  });

  factory CoursePrerequisiteModel.fromJson(Map<String, dynamic> json) {
    return CoursePrerequisiteModel(
      id: json['id'],
      courseId: json['course_id'],
      prerequisiteCourseId: json['prerequisite_course_id'],
    );
  }
}
