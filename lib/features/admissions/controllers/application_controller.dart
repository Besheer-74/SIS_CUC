import 'package:flutter/material.dart';

import '../../../core/config/supabase_config.dart';
import '../models/admission_lookup_option.dart';
import '../models/new_application_model.dart';

class ApplicationController extends ChangeNotifier {
  static const int totalSteps = 7;

  NewApplicationModel _application = NewApplicationModel();

  NewApplicationModel get application => _application;

  int _currentStep = 1;
  int get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _password = '';

  List<AdmissionLookupOption> _certificateTypes = [];
  List<AdmissionLookupOption> _certificateSpecializations = [];
  List<AdmissionLookupOption> _allowedFaculties = [];
  List<AdmissionLookupOption> _majors = [];

  List<AdmissionLookupOption> get certificateTypes => _certificateTypes;
  List<AdmissionLookupOption> get certificateSpecializations =>
      _certificateSpecializations;
  List<AdmissionLookupOption> get allowedFaculties => _allowedFaculties;
  List<AdmissionLookupOption> get majors => _majors;

  bool _isLoadingCertificateTypes = false;
  bool _isLoadingCertificateSpecializations = false;
  bool _isLoadingAllowedFaculties = false;
  bool _isLoadingMajors = false;

  bool get isLoadingCertificateTypes => _isLoadingCertificateTypes;
  bool get isLoadingCertificateSpecializations =>
      _isLoadingCertificateSpecializations;
  bool get isLoadingAllowedFaculties => _isLoadingAllowedFaculties;
  bool get isLoadingMajors => _isLoadingMajors;

  String? _lookupErrorMessage;
  String? get lookupErrorMessage => _lookupErrorMessage;

  void nextStep() {
    if (_currentStep < totalSteps) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void updateStep1({
    required String nationality,
    required String nationalId,
    required String password,
  }) {
    _application.nationality = nationality.trim();
    _application.nationalId = nationalId.trim();
    _password = password;

    notifyListeners();
  }

  void updateStep2({
    required String firstNameEn,
    required String middleNameEn,
    required String familyNameEn,
    String? firstNameAr,
    String? middleNameAr,
    String? familyNameAr,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    _application.fullNameEn =
        '${firstNameEn.trim()} ${middleNameEn.trim()} ${familyNameEn.trim()}';

    final arabicParts = [
      firstNameAr?.trim(),
      middleNameAr?.trim(),
      familyNameAr?.trim(),
    ].where((element) => element != null && element.isNotEmpty).join(' ');

    _application.fullNameAr = arabicParts.isEmpty ? null : arabicParts;
    _application.dateOfBirth = dateOfBirth;
    _application.gender = gender?.toLowerCase().trim();

    notifyListeners();
  }

  void updateStep3({
    required String email,
    required String mobile,
    String? alternateMobile,
    String? guardianEmail,
  }) {
    _application.email = email.trim();
    _application.mobile = mobile.trim();
    _application.alternateMobile = alternateMobile?.trim();
    _application.guardianEmail = guardianEmail?.trim();

    notifyListeners();
  }

  void updateStep4({
    required String schoolName,
    double? highSchoolGrade,
    required int certificateTypeId,
    required int certificateSpecializationId,
  }) {
    _application.schoolName = schoolName.trim();
    _application.highSchoolGrade = highSchoolGrade;
    _application.certificateTypeId = certificateTypeId;
    _application.certificateSpecializationId = certificateSpecializationId;

    notifyListeners();
  }

  void updateStep5({required int facultyId, required int majorId}) {
    _application.facultyId = facultyId;
    _application.majorId = majorId;

    notifyListeners();
  }

  Future<void> loadCertificateTypes() async {
    if (_certificateTypes.isNotEmpty || _isLoadingCertificateTypes) {
      return;
    }

    _isLoadingCertificateTypes = true;
    _lookupErrorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseConfig.client
          .from('certificate_types')
          .select()
          .order('name');

      _certificateTypes = _toLookupOptions(response);
    } catch (error) {
      _lookupErrorMessage = 'Unable to load certificate types.';
      debugPrint('Error loading certificate types: $error');
    } finally {
      _isLoadingCertificateTypes = false;
      notifyListeners();
    }
  }

  Future<void> loadCertificateSpecializations(int certificateTypeId) async {
    _isLoadingCertificateSpecializations = true;
    _lookupErrorMessage = null;
    _certificateSpecializations = [];
    _allowedFaculties = [];
    _majors = [];
    _application.certificateTypeId = certificateTypeId;
    _application.certificateSpecializationId = null;
    _application.facultyId = null;
    _application.majorId = null;
    notifyListeners();

    try {
      final response = await SupabaseConfig.client
          .from('certificate_specializations')
          .select()
          .eq('certificate_type_id', certificateTypeId)
          .order('name');

      _certificateSpecializations = _toLookupOptions(response);
    } catch (error) {
      _lookupErrorMessage = 'Unable to load certificate specializations.';
      debugPrint('Error loading certificate specializations: $error');
    } finally {
      _isLoadingCertificateSpecializations = false;
      notifyListeners();
    }
  }

  Future<void> loadAllowedFaculties(int certificateSpecializationId) async {
    _isLoadingAllowedFaculties = true;
    _lookupErrorMessage = null;
    _allowedFaculties = [];
    _majors = [];
    _application.certificateSpecializationId = certificateSpecializationId;
    _application.facultyId = null;
    _application.majorId = null;
    notifyListeners();

    try {
      final ruleRows = await SupabaseConfig.client
          .from('faculty_specialization_rules')
          .select('faculty_id')
          .eq('certificate_specialization_id', certificateSpecializationId);

      final facultyIds = _toIntList(ruleRows, 'faculty_id');
      if (facultyIds.isEmpty) {
        _allowedFaculties = [];
        return;
      }

      final facultyRows = await SupabaseConfig.client
          .from('faculties')
          .select()
          .inFilter('id', facultyIds)
          .eq('is_active', true)
          .order('name');

      _allowedFaculties = _toLookupOptions(facultyRows);
    } catch (error) {
      _lookupErrorMessage = 'Unable to load eligible faculties.';
      debugPrint('Error loading eligible faculties: $error');
    } finally {
      _isLoadingAllowedFaculties = false;
      notifyListeners();
    }
  }

  Future<void> loadMajors(int facultyId) async {
    _isLoadingMajors = true;
    _lookupErrorMessage = null;
    _majors = [];
    _application.facultyId = facultyId;
    _application.majorId = null;
    notifyListeners();

    try {
      final response = await SupabaseConfig.client
          .from('majors')
          .select()
          .eq('faculty_id', facultyId)
          .order('name');

      _majors = _toLookupOptions(response);
    } catch (error) {
      _lookupErrorMessage = 'Unable to load majors.';
      debugPrint('Error loading majors: $error');
    } finally {
      _isLoadingMajors = false;
      notifyListeners();
    }
  }

  String generateApplicationNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);

    return 'CUC-2026-$timestamp';
  }

  Future<bool> submitApplication() async {
    _isLoading = true;
    _errorMessage = null;
    String? userId;

    notifyListeners();

    try {
      final authResponse = await SupabaseConfig.client.auth.signUp(
        email: _application.email,
        password: _password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user');
      }

      userId = authResponse.user!.id;
      _application.userId = userId;

      await SupabaseConfig.client.from('profiles').insert({
        'id': userId,
        'role': 'student',
        'full_name': _application.fullNameEn,
        'email': _application.email,
      });

      _application.applicationNumber = generateApplicationNumber();

      final result = await SupabaseConfig.client
          .from('applications')
          .insert(_application.toJson())
          .select()
          .single();

      _application.id = result['id'];

      return true;
    } catch (error) {
      _errorMessage = error.toString();
      if (userId != null) {
        await SupabaseConfig.client.from('profiles').delete().eq('id', userId);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetApplication() {
    _application = NewApplicationModel();
    _currentStep = 1;
    _password = '';
    _errorMessage = null;
    _lookupErrorMessage = null;
    _certificateSpecializations = [];
    _allowedFaculties = [];
    _majors = [];

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String lookupNameFor(String group, int? id) {
    if (id == null) {
      return '-';
    }

    final options = switch (group) {
      'certificateType' => _certificateTypes,
      'certificateSpecialization' => _certificateSpecializations,
      'faculty' => _allowedFaculties,
      'major' => _majors,
      _ => const <AdmissionLookupOption>[],
    };

    for (final option in options) {
      if (option.id == id) {
        return option.name;
      }
    }

    return '#$id';
  }

  Future<bool> hasApplication() async {
    try {
      final userId = SupabaseConfig.currentUserId;

      if (userId == null) {
        return false;
      }

      final result = await SupabaseConfig.client
          .from('applications')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      return result != null;
    } catch (e) {
      debugPrint('Has application error: $e');
      return false;
    }
  }

  Future<NewApplicationModel?> loadApplication() async {
    try {
      final userId = SupabaseConfig.currentUserId;

      if (userId == null) {
        return null;
      }

      final result = await SupabaseConfig.client
          .from('applications')
          .select()
          .eq('user_id', userId)
          .single();

      _application = NewApplicationModel.fromJson(result);

      notifyListeners();

      return _application;
    } catch (e) {
      debugPrint('Load application error: $e');
      return null;
    }
  }

  List<AdmissionLookupOption> _toLookupOptions(Object? response) {
    final rows = (response as List<dynamic>).cast<Map<String, dynamic>>();
    return rows.map(AdmissionLookupOption.fromJson).toList();
  }

  List<int> _toIntList(Object? response, String key) {
    final rows = (response as List<dynamic>).cast<Map<String, dynamic>>();

    return rows
        .map((row) => int.tryParse(row[key]?.toString() ?? ''))
        .whereType<int>()
        .toSet()
        .toList();
  }
}
