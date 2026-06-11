import 'package:flutter/foundation.dart';

import '../../../core/config/supabase_config.dart';
import '../../dashboard/models/application_document_model.dart';
import '../../dashboard/models/application_model.dart';
import '../models/student_model.dart';

class AdminController extends ChangeNotifier {
  List<ApplicationModel> _applications = [];
  List<ApplicationModel> get applications => _applications;

  List<ApplicationModel> _filteredApplications = [];
  List<ApplicationModel> get filteredApplications => _filteredApplications;

  ApplicationModel? _currentApplication;
  ApplicationModel? get currentApplication => _currentApplication;

  List<ApplicationDocumentModel> _documents = [];
  List<ApplicationDocumentModel> get documents => _documents;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  List<StudentModel> _filteredStudents = [];
  List<StudentModel> get filteredStudents => _filteredStudents;

  Map<String, dynamic> _studentDetails = {};
  Map<String, dynamic> get studentDetails => _studentDetails;


  final Map<int, String> _facultyNameCache = {};
  final Map<int, String> _certificateTypeNameCache = {};
  final Map<int, String> _specializationNameCache = {};
  final Map<int, String> _majorNameCache = {};

  String getFacultyName(int? facultyId) {
    if (facultyId == null) return '-';
    return _facultyNameCache[facultyId] ?? '-';
  }

  String getCertificateTypeName(int? certId) {
    if (certId == null) return '-';
    return _certificateTypeNameCache[certId] ?? '-';
  }

  String getCertificateSpecializationName(int? specId) {
    if (specId == null) return '-';
    return _specializationNameCache[specId] ?? '-';
  }

  String getMajorName(int? majorId) {
    if (majorId == null) return '-';
    return _majorNameCache[majorId] ?? '-';
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  ApplicationStatus? _selectedStatus;
  ApplicationStatus? get selectedStatus => _selectedStatus;

  Future<void> loadApplications({bool forceRefresh = false}) async {
    if (_isLoading || (_applications.isNotEmpty && !forceRefresh)) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rows = await SupabaseConfig.client
          .from('applications')
          .select()
          .order('created_at', ascending: false);

      _applications = (rows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(ApplicationModel.fromJson)
          .toList();

      // Pre‑fetch all related names
      await _prefetchRelatedNames();

      _applyFilters();
    } catch (error) {
      _errorMessage = 'Unable to load applications';
      debugPrint('Admin applications load error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _prefetchRelatedNames() async {
    final facultyIds = <int>{};
    final certTypeIds = <int>{};
    final specIds = <int>{};
    final majorIds = <int>{};

    for (final app in _applications) {
      if (app.facultyId != null) facultyIds.add(app.facultyId!);
      if (app.certificateTypeId != null)
        certTypeIds.add(app.certificateTypeId!);
      if (app.certificateSpecializationId != null)
        specIds.add(app.certificateSpecializationId!);
      if (app.majorId != null) majorIds.add(app.majorId!);
    }

    if (facultyIds.isNotEmpty) {
      final faculties = await SupabaseConfig.client
          .from('faculties')
          .select('id, name')
          .inFilter('id', facultyIds.toList());
      for (final f in faculties) {
        _facultyNameCache[f['id']] = f['name'] as String? ?? '-';
      }
    }

    if (certTypeIds.isNotEmpty) {
      final types = await SupabaseConfig.client
          .from('certificate_types')
          .select('id, name')
          .inFilter('id', certTypeIds.toList());
      for (final t in types) {
        _certificateTypeNameCache[t['id']] = t['name'] as String? ?? '-';
      }
    }

    // Load specializations
    if (specIds.isNotEmpty) {
      final specs = await SupabaseConfig.client
          .from('certificate_specializations')
          .select('id, name')
          .inFilter('id', specIds.toList());
      for (final s in specs) {
        _specializationNameCache[s['id']] = s['name'] as String? ?? '-';
      }
    }

    if (majorIds.isNotEmpty) {
      final majors = await SupabaseConfig.client
          .from('majors')
          .select('id, name')
          .inFilter('id', majorIds.toList());
      for (final m in majors) {
        _majorNameCache[m['id']] = m['name'] as String? ?? '-';
      }
    }
  }

  Future<void> loadApplicationById(String applicationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final appJson = await SupabaseConfig.client
          .from('applications')
          .select()
          .eq('id', applicationId)
          .single();

      _currentApplication = ApplicationModel.fromJson(appJson);

      await _loadApplicationDocuments(applicationId);
    } catch (error) {
      _errorMessage = 'Unable to load application details';
      debugPrint('Load application error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadApplicationDocuments(String applicationId) async {
    try {
      final rows = await SupabaseConfig.client
          .from('application_documents')
          .select()
          .eq('application_id', applicationId)
          .order('created_at', ascending: false);

      _documents = (rows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(ApplicationDocumentModel.fromJson)
          .toList();
    } catch (error) {
      debugPrint('Documents load error: $error');
      _documents = [];
    }
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus newStatus,
    required String reviewComment,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUserId = SupabaseConfig.currentUserId;

      await SupabaseConfig.client
          .from('applications')
          .update({
            'status': newStatus.value,
            'review_comment': reviewComment.isNotEmpty ? reviewComment : null,
            'reviewed_by': currentUserId,
            'reviewed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', applicationId);

      if (_currentApplication != null) {
        _currentApplication = ApplicationModel(
          id: _currentApplication!.id,
          applicationNumber: _currentApplication!.applicationNumber,
          userId: _currentApplication!.userId,
          applicantType: _currentApplication!.applicantType,
          semester: _currentApplication!.semester,
          fullNameEn: _currentApplication!.fullNameEn,
          fullNameAr: _currentApplication!.fullNameAr,
          nationality: _currentApplication!.nationality,
          nationalId: _currentApplication!.nationalId,
          email: _currentApplication!.email,
          mobile: _currentApplication!.mobile,
          alternateMobile: _currentApplication!.alternateMobile,
          certificateTypeId: _currentApplication!.certificateTypeId,
          certificateSpecializationId:
              _currentApplication!.certificateSpecializationId,
          schoolName: _currentApplication!.schoolName,
          highSchoolGrade: _currentApplication!.highSchoolGrade,
          facultyId: _currentApplication!.facultyId,
          majorId: _currentApplication!.majorId,
          status: newStatus,
          reviewComment: reviewComment.isNotEmpty ? reviewComment : null,
          reviewedBy: currentUserId,
          reviewedAt: DateTime.now(),
          createdAt: _currentApplication!.createdAt,
          updatedAt: DateTime.now(),
          dateOfBirth: _currentApplication!.dateOfBirth,
          gender: _currentApplication!.gender,
          guardianEmail: _currentApplication!.guardianEmail,
        );
      }

      if (newStatus == ApplicationStatus.approved) {
        await _createStudentIfNotExists();
      }

      // Refresh the list (and caches)
      await loadApplications(forceRefresh: true);
    } catch (error) {
      _errorMessage = 'Failed to update application status';
      debugPrint('Update application error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createStudentIfNotExists() async {
    if (_currentApplication == null) return;

    try {
      final existing = await SupabaseConfig.client
          .from('students')
          .select()
          .eq('application_id', _currentApplication!.id)
          .maybeSingle();

      if (existing != null) {
        debugPrint('Student already exists for this application');
        return;
      }

      final studentCode = await _generateNextStudentCode();

      await SupabaseConfig.client.from('students').insert({
        'id': _currentApplication!.userId,
        'application_id': _currentApplication!.id,
        'student_code': studentCode,
        'faculty_id': _currentApplication!.facultyId,
        'major_id': _currentApplication!.majorId,
        'current_semester': 1,
        'max_credit_hours': 18,
        'status': 'active',
      });

      debugPrint('Student record created: $studentCode');
    } catch (error) {
      debugPrint('Create student error: $error');
    }
  }

  Future<String> _generateNextStudentCode() async {
    try {
      final result = await SupabaseConfig.client
          .from('students')
          .select('student_code')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      int nextNumber = 1;
      if (result != null) {
        final lastCode = result['student_code'] as String;
        final numberStr = lastCode.substring(3);
        final lastNumber = int.parse(numberStr);
        nextNumber = lastNumber + 1;
      }

      return 'CUC${nextNumber.toString().padLeft(5, '0')}';
    } catch (error) {
      debugPrint('Generate student code error: $error');
      return 'CUC${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    }
  }

  Future<void> loadStudents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rows = await SupabaseConfig.client
          .from('students')
          .select()
          .order('created_at', ascending: false);

      _students = (rows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(StudentModel.fromJson)
          .toList();

      _filteredStudents = _students;
    } catch (error) {
      _errorMessage = 'Unable to load students';
      debugPrint('Load students error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStudentSearchQuery(String query) {
    _searchQuery = query;
    _applyStudentFilters();
    notifyListeners();
  }

  void _applyStudentFilters() {
    _filteredStudents = _students.where((student) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          student.studentCode.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesSearch;
    }).toList();
  }

  Future<Map<String, dynamic>> getStudentDetails(String studentId) async {
    try {
      final result = await SupabaseConfig.client
          .from('students')
          .select(
            '*, applications:application_id(*), faculties:faculty_id(name), majors:major_id(name)',
          )
          .eq('id', studentId)
          .single();

      _studentDetails = result;
      return result;
    } catch (error) {
      debugPrint('Get student details error: $error');
      return {};
    }
  }

  Future<Map<String, dynamic>> getApplicationDetails(
    String applicationId,
  ) async {
    try {
      final result = await SupabaseConfig.client
          .from('applications')
          .select()
          .eq('id', applicationId)
          .single();

      return result;
    } catch (error) {
      debugPrint('Get application details error: $error');
      return {};
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(ApplicationStatus? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredApplications = _applications.where((app) {
      final matchesStatus =
          _selectedStatus == null || app.status == _selectedStatus;

      final matchesSearch =
          _searchQuery.isEmpty ||
          app.applicationNumber.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          app.fullNameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          app.nationalId.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesStatus && matchesSearch;
    }).toList();
  }

  int get pendingCount => _applications
      .where((app) => app.status == ApplicationStatus.pending)
      .length;

  int get approvedCount => _applications
      .where((app) => app.status == ApplicationStatus.approved)
      .length;

  int get rejectedCount => _applications
      .where((app) => app.status == ApplicationStatus.rejected)
      .length;

  int get totalCount => _applications.length;

  List<ApplicationModel> get recentApplications =>
      _applications.take(5).toList();

  Future<void> refresh() async {
    _applications = [];
    _filteredApplications = [];
    _facultyNameCache.clear();
    _certificateTypeNameCache.clear();
    _specializationNameCache.clear();
    _majorNameCache.clear();
    await loadApplications(forceRefresh: true);
  }
}