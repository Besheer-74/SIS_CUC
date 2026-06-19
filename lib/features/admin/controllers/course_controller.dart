import 'package:flutter/material.dart';

import '../../../core/config/supabase_config.dart';
import '../models/course_model.dart';
import '../models/course_prerequisite_model.dart';
import '../models/student_available_course_model.dart';

class CourseController extends ChangeNotifier {
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CourseModel> _facultyCourses = [];
  List<CourseModel> get facultyCourses => _facultyCourses;

  List<StudentAvailableCourseModel> _studentAvailableCourses = [];
  List<StudentAvailableCourseModel> get studentAvailableCourses =>
      _studentAvailableCourses;

  final Map<int, CoursePrerequisiteModel> _coursePrerequisites = {};
  Map<int, CoursePrerequisiteModel> get coursePrerequisites =>
      _coursePrerequisites;

  final Map<int, String> _courseNameCache = {};

  String getCourseName(int? courseId) {
    if (courseId == null) return '-';
    return _courseNameCache[courseId] ?? '-';
  }

  Future<void> loadFacultyCourses(int facultyId) async {
    try {
      final rows = await SupabaseConfig.client
          .from('courses')
          .select()
          .eq('faculty_id', facultyId)
          .order('course_code', ascending: true);

      _facultyCourses = (rows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(CourseModel.fromJson)
          .toList();

      _courseNameCache.clear();
      for (final course in _facultyCourses) {
        _courseNameCache[course.id] = course.name;
      }

      await _loadCoursePrerequisites();
    } catch (error) {
      debugPrint('Load faculty courses error: $error');
      _errorMessage = 'Unable to load faculty courses';
      _facultyCourses = [];
    }
  }

  Future<void> _loadCoursePrerequisites() async {
    try {
      final courseIds = _facultyCourses.map((c) => c.id).toList();
      if (courseIds.isEmpty) return;

      final rows = await SupabaseConfig.client
          .from('course_prerequisites')
          .select()
          .inFilter('course_id', courseIds);

      _coursePrerequisites.clear();
      for (final prereq in rows) {
        final model = CoursePrerequisiteModel.fromJson(prereq);
        _coursePrerequisites[model.courseId] = model;
      }
    } catch (error) {
      debugPrint('Load course prerequisites error: $error');
    }
  }

  Future<void> loadStudentAvailableCourses(String studentId) async {
    try {
      final rows = await SupabaseConfig.client
          .from('student_available_courses')
          .select()
          .eq('student_id', studentId)
          .order('created_at', ascending: true);

      _studentAvailableCourses = (rows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(StudentAvailableCourseModel.fromJson)
          .toList();
    } catch (error) {
      debugPrint('Load student available courses error: $error');
      _studentAvailableCourses = [];
    }
  }

  bool isCourseEnabled(int courseId) {
    return _studentAvailableCourses.any(
      (sac) => sac.courseId == courseId && sac.isEnabled,
    );
  }

  Future<void> enableCourse({
    required String studentId,
    required int courseId,
    required int semester,
  }) async {
    try {
      final existing = await SupabaseConfig.client
          .from('student_available_courses')
          .select()
          .eq('student_id', studentId)
          .eq('course_id', courseId)
          .maybeSingle();

      if (existing != null) {
        await SupabaseConfig.client
            .from('student_available_courses')
            .update({'is_enabled': true})
            .eq('student_id', studentId)
            .eq('course_id', courseId);
      } else {
        await SupabaseConfig.client.from('student_available_courses').insert({
          'student_id': studentId,
          'course_id': courseId,
          'semester': semester,
          'is_enabled': true,
        });
      }

      await loadStudentAvailableCourses(studentId);
      notifyListeners();
    } catch (error) {
      debugPrint('Enable course error: $error');
      _errorMessage = 'Failed to enable course';
      notifyListeners();
    }
  }

  Future<void> disableCourse({
    required String studentId,
    required int courseId,
  }) async {
    try {
      await SupabaseConfig.client
          .from('student_available_courses')
          .update({'is_enabled': false})
          .eq('student_id', studentId)
          .eq('course_id', courseId);

      await loadStudentAvailableCourses(studentId);
      notifyListeners();
    } catch (error) {
      debugPrint('Disable course error: $error');
      _errorMessage = 'Failed to disable course';
      notifyListeners();
    }
  }

  int get totalFacultyCourses => _facultyCourses.length;

  int get enabledCoursesCount =>
      _studentAvailableCourses.where((sac) => sac.isEnabled).length;

  int get disabledCoursesCount =>
      _studentAvailableCourses.where((sac) => !sac.isEnabled).length;
}
