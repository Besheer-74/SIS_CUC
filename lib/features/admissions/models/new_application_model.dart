class NewApplicationModel {
  String? id;
  String applicationNumber = '';
  String? userId;

  // Application Info
  String applicantType = 'new_applicant';
  String semester = '2026/2027 - Fall';

  // Personal Info
  String fullNameEn = '';
  String? fullNameAr;

  String nationality = 'Egypt';
  String nationalId = '';

  DateTime? dateOfBirth;
  String? gender;

  // Contact Info
  String email = '';
  String? guardianEmail;

  String mobile = '';
  String? alternateMobile;

  // Academic Info
  int? certificateTypeId;
  int? certificateSpecializationId;

  String schoolName = '';
  double? highSchoolGrade;

  // Admission Info
  int? facultyId;
  int? majorId;

  // Workflow
  String status = 'pending';

  NewApplicationModel();

  Map<String, dynamic> toJson() {
    return {
      'application_number': applicationNumber,
      'user_id': userId,

      'applicant_type': applicantType,
      'semester': semester,

      'full_name_en': fullNameEn,
      'full_name_ar': fullNameAr,

      'nationality': nationality,
      'national_id': nationalId,

      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,

      'email': email,
      'guardian_email': guardianEmail,

      'mobile': mobile,
      'alternate_mobile': alternateMobile,

      'certificate_type_id': certificateTypeId,
      'certificate_specialization_id': certificateSpecializationId,

      'school_name': schoolName,
      'high_school_grade': highSchoolGrade,

      'faculty_id': facultyId,
      'major_id': majorId,

      'status': status,
    };
  }

  factory NewApplicationModel.fromJson(Map<String, dynamic> json) {
    return NewApplicationModel()
      ..id = json['id']
      ..applicationNumber = json['application_number'] ?? ''
      ..userId = json['user_id']
      ..applicantType = json['applicant_type'] ?? 'new_applicant'
      ..semester = json['semester'] ?? '2026/2027 - Fall'
      ..fullNameEn = json['full_name_en'] ?? ''
      ..fullNameAr = json['full_name_ar']
      ..nationality = json['nationality'] ?? 'Egypt'
      ..nationalId = json['national_id'] ?? ''
      ..dateOfBirth = json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null
      ..gender = json['gender']
      ..email = json['email'] ?? ''
      ..guardianEmail = json['guardian_email']
      ..mobile = json['mobile'] ?? ''
      ..alternateMobile = json['alternate_mobile']
      ..certificateTypeId = json['certificate_type_id']
      ..certificateSpecializationId = json['certificate_specialization_id']
      ..schoolName = json['school_name'] ?? ''
      ..highSchoolGrade = json['high_school_grade'] != null
          ? (json['high_school_grade'] as num).toDouble()
          : null
      ..facultyId = json['faculty_id']
      ..majorId = json['major_id']
      ..status = json['status'] ?? 'pending';
  }
}
