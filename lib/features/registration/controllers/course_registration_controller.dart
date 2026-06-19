import 'package:flutter/foundation.dart';

import '../../../core/config/supabase_config.dart';
import '../../admin/models/student_model.dart';
import '../models/course_model.dart';
import '../models/registration_record_model.dart';

class CourseRegistrationController extends ChangeNotifier {
  StudentModel? _student;
  StudentModel? get student => _student;

  List<AvailableRegistrationCourse> _availableCourses = [];
  List<AvailableRegistrationCourse> get availableCourses => _availableCourses;

  List<RegistrationRecordModel> _registeredCourses = [];
  List<RegistrationRecordModel> get registeredCourses => _registeredCourses;

  final Map<int, List<int>> _prerequisiteIdsByCourse = {};
  final Map<int, String> _courseNameById = {};
  final Set<int> _completedCourseIds = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isRegistering = false;
  bool get isRegistering => _isRegistering;

  bool _isDropping = false;
  bool get isDropping => _isDropping;

  // Placeholder until a registration settings table is introduced.
  bool _isRegistrationOpen = true;
  bool get isRegistrationOpen => _isRegistrationOpen;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  int get registeredCoursesCount => _registeredCourses.length;

  int get totalRegisteredCredits => _registeredCourses.fold<int>(
    0,
    (total, record) => total + record.course.creditHours,
  );

  int get maxCreditHours => _student?.maxCreditHours ?? 0;

  int get remainingCreditHours {
    final remaining = maxCreditHours - totalRegisteredCredits;
    return remaining < 0 ? 0 : remaining;
  }

  Future<void> loadForCurrentStudent() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        throw Exception('No authenticated student found.');
      }

      final studentRow = await SupabaseConfig.client
          .from('students')
          .select()
          .eq('id', userId)
          .single();

      _student = StudentModel.fromJson(studentRow);
      _isRegistrationOpen = true;

      await Future.wait([
        _loadAvailableCourses(userId),
        _loadRegisteredCourses(userId),
        _loadCompletedCourses(userId),
      ]);

      await _loadPrerequisites();
    } catch (error) {
      _errorMessage = 'Unable to load course registration.';
      debugPrint('Student course registration load error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerCourse(AvailableRegistrationCourse item) async {
    final student = _student;
    if (student == null || _isRegistering) {
      return;
    }

    _isRegistering = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (!_isRegistrationOpen) {
        _errorMessage = 'Course registration is currently closed.';
        return;
      }

      if (isRegistered(item.course.id)) {
        _errorMessage = 'This course is already registered.';
        return;
      }

      final missingPrerequisites = _missingPrerequisites(item.course.id);
      if (missingPrerequisites.isNotEmpty) {
        _errorMessage = 'Prerequisite requirements are not satisfied.';
        return;
      }

      if (totalRegisteredCredits + item.course.creditHours >
          student.maxCreditHours) {
        _errorMessage = 'Maximum credit hours exceeded.';
        return;
      }

      await SupabaseConfig.client.from('registrations').insert({
        'student_id': student.id,
        'course_id': item.course.id,
        'semester': student.currentSemester.toString(),
        'status': 'registered',
      });

      _successMessage = 'Course registered successfully.';
      await _loadRegisteredCourses(student.id);
    } catch (error) {
      _errorMessage = 'Unable to register this course.';
      debugPrint('Register course error: $error');
    } finally {
      _isRegistering = false;
      notifyListeners();
    }
  }

  Future<void> dropCourse(RegistrationRecordModel record) async {
    final student = _student;
    if (student == null || _isDropping) {
      return;
    }

    _isDropping = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (!_isRegistrationOpen) {
        _errorMessage = 'Course registration is currently closed.';
        return;
      }

      await SupabaseConfig.client
          .from('registrations')
          .update({'status': 'dropped'})
          .eq('id', record.id);

      _successMessage = 'Course dropped successfully.';
      await _loadRegisteredCourses(student.id);
    } catch (error) {
      _errorMessage = 'Unable to drop this course.';
      debugPrint('Drop course error: $error');
    } finally {
      _isDropping = false;
      notifyListeners();
    }
  }

  bool isRegistered(int courseId) {
    return _registeredCourses.any(
      (record) => record.course.id == courseId && record.status == 'registered',
    );
  }

  String prerequisiteLabelFor(int courseId) {
    final prerequisiteIds = _prerequisiteIdsByCourse[courseId] ?? const <int>[];
    if (prerequisiteIds.isEmpty) {
      return 'None';
    }

    return prerequisiteIds.map((id) => _courseNameById[id] ?? '#$id').join(', ');
  }

  Future<void> _loadAvailableCourses(String studentId) async {
    final rows = await SupabaseConfig.client
        .from('student_available_courses')
        .select('*, courses:course_id(*)')
        .eq('student_id', studentId)
        .eq('is_enabled', true)
        .order('created_at', ascending: true);

    _availableCourses = (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(AvailableRegistrationCourse.fromJson)
        .where((item) => item.course.id > 0)
        .toList();

    for (final item in _availableCourses) {
      _courseNameById[item.course.id] = item.course.name;
    }
  }

  Future<void> _loadRegisteredCourses(String studentId) async {
    final rows = await SupabaseConfig.client
        .from('registrations')
        .select('*, courses:course_id(*)')
        .eq('student_id', studentId)
        .eq('status', 'registered')
        .order('created_at', ascending: true);

    _registeredCourses = (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(RegistrationRecordModel.fromJson)
        .toList();

    for (final record in _registeredCourses) {
      _courseNameById[record.course.id] = record.course.name;
    }
  }

  Future<void> _loadCompletedCourses(String studentId) async {
    try {
      final rows = await SupabaseConfig.client
          .from('student_completed_courses')
          .select('course_id')
          .eq('student_id', studentId);

      _setCompletedCourses(rows);
    } catch (error) {
      final rows = await SupabaseConfig.client
          .from('completed_courses')
          .select('course_id')
          .eq('student_id', studentId);

      _setCompletedCourses(rows);
    }
  }

  void _setCompletedCourses(Object? rows) {
    _completedCourseIds
      ..clear()
      ..addAll(
        (rows as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map((row) => int.tryParse(row['course_id']?.toString() ?? ''))
            .whereType<int>(),
      );
  }

  Future<void> _loadPrerequisites() async {
    _prerequisiteIdsByCourse.clear();

    final courseIds = _availableCourses.map((item) => item.course.id).toList();
    if (courseIds.isEmpty) {
      return;
    }

    final rows = await SupabaseConfig.client
        .from('course_prerequisites')
        .select('course_id, prerequisite_course_id')
        .inFilter('course_id', courseIds);

    final prerequisiteIds = <int>{};

    for (final row in (rows as List<dynamic>).cast<Map<String, dynamic>>()) {
      final courseId = int.tryParse(row['course_id']?.toString() ?? '');
      final prerequisiteId = int.tryParse(
        row['prerequisite_course_id']?.toString() ?? '',
      );

      if (courseId == null || prerequisiteId == null) {
        continue;
      }

      _prerequisiteIdsByCourse
          .putIfAbsent(courseId, () => <int>[])
          .add(prerequisiteId);
      prerequisiteIds.add(prerequisiteId);
    }

    await _loadPrerequisiteNames(prerequisiteIds);
  }

  Future<void> _loadPrerequisiteNames(Set<int> prerequisiteIds) async {
    final missingIds = prerequisiteIds
        .where((id) => !_courseNameById.containsKey(id))
        .toList();

    if (missingIds.isEmpty) {
      return;
    }

    final rows = await SupabaseConfig.client
        .from('courses')
        .select('id, course_code, course_name, credit_hours')
        .inFilter('id', missingIds);

    for (final row in (rows as List<dynamic>).cast<Map<String, dynamic>>()) {
      final course = RegistrationCourseModel.fromJson(row);
      _courseNameById[course.id] = course.code;
    }
  }

  List<int> _missingPrerequisites(int courseId) {
    final prerequisiteIds = _prerequisiteIdsByCourse[courseId] ?? const <int>[];
    return prerequisiteIds
        .where((prerequisiteId) => !_completedCourseIds.contains(prerequisiteId))
        .toList();
  }
}
