import 'package:flutter/foundation.dart';

import '../../../core/config/supabase_config.dart';
import '../models/application_document_model.dart';
import '../models/application_model.dart';
import '../models/application_review_log_model.dart';

class ApplicantDashboardController extends ChangeNotifier {
  ApplicationModel? _application;
  ApplicationModel? get application => _application;

  List<ApplicationDocumentModel> _documents = [];
  List<ApplicationDocumentModel> get documents => _documents;

  List<ApplicationReviewLogModel> _reviewLogs = [];
  List<ApplicationReviewLogModel> get reviewLogs => _reviewLogs;

  String? _facultyName;
  String get facultyName => _facultyName ?? '-';

  String? _majorName;
  String get majorName => _majorName ?? '-';

  String? _certificateTypeName;
  String get certificateTypeName => _certificateTypeName ?? '-';

  String? _specializationName;
  String get specializationName => _specializationName ?? '-';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    if (_isLoading || (_application != null && !forceRefresh)) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = SupabaseConfig.currentUserId;

      if (userId == null) {
        throw Exception('No authenticated applicant found.');
      }

      final applicationJson = await SupabaseConfig.client
          .from('applications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (applicationJson == null) {
        _errorMessage = 'No submitted application was found for this account.';
        return;
      }

      _application = ApplicationModel.fromJson(applicationJson);

      await Future.wait([
        _loadLookupNames(),
        _loadDocuments(_application!.id),
        _loadReviewLogs(_application!.id),
      ]);
    } catch (error) {
      _errorMessage = 'Unable to load applicant dashboard right now.';
      debugPrint('Applicant dashboard load error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadLookupNames() async {
    if (_application == null) return;

    _facultyName = await _lookupName(
      table: 'faculties',
      id: _application!.facultyId,
    );

    _majorName = await _lookupName(table: 'majors', id: _application!.majorId);

    _certificateTypeName = await _lookupName(
      table: 'certificate_types',
      id: _application!.certificateTypeId,
    );

    _specializationName = await _lookupName(
      table: 'certificate_specializations',
      id: _application!.certificateSpecializationId,
    );
  }

  Future<String> _lookupName({
    required String table,
    required Object? id,
  }) async {
    if (id == null) {
      return '-';
    }

    try {
      final row = await SupabaseConfig.client
          .from(table)
          .select('name')
          .eq('id', id)
          .maybeSingle();

      final name = row?['name']?.toString().trim();

      if (name == null || name.isEmpty) {
        return '#$id';
      }

      return name;
    } catch (error) {
      debugPrint('Lookup error for $table/$id: $error');
      return '#$id';
    }
  }

  Future<void> _loadDocuments(String applicationId) async {
    try {
      final rows = await SupabaseConfig.client
          .from('application_documents')
          .select()
          .eq('application_id', applicationId)
          .order('created_at');

      _documents = (rows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(ApplicationDocumentModel.fromJson)
          .toList();
    } catch (error) {
      debugPrint('Documents load error: $error');
      _documents = [];
    }
  }

  Future<void> _loadReviewLogs(String applicationId) async {
    try {
      final rows = await SupabaseConfig.client
          .from('application_review_logs')
          .select()
          .eq('application_id', applicationId)
          .order('created_at', ascending: false);

      _reviewLogs = (rows as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(ApplicationReviewLogModel.fromJson)
          .toList();
    } catch (error) {
      debugPrint('Review logs load error: $error');
      _reviewLogs = [];
    }
  }

  Future<void> refresh() async {
    _application = null;
    await loadDashboard(forceRefresh: true);
  }

  bool get isApproved => _application?.status == ApplicationStatus.approved;
}
