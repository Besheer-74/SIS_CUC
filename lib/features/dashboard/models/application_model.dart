import 'package:flutter/material.dart';

enum ApplicationStatus {
  pending,
  underReview,
  approved,
  rejected;

  factory ApplicationStatus.fromString(String value) {
    switch (value) {
      case 'under_review':
        return ApplicationStatus.underReview;
      case 'approved':
        return ApplicationStatus.approved;
      case 'rejected':
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case ApplicationStatus.pending:
        return 'pending';
      case ApplicationStatus.underReview:
        return 'under_review';
      case ApplicationStatus.approved:
        return 'approved';
      case ApplicationStatus.rejected:
        return 'rejected';
    }
  }

  String get label {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending Review';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  String get message {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Your application is waiting for review.';
      case ApplicationStatus.underReview:
        return 'Your application is currently under review.';
      case ApplicationStatus.approved:
        return 'Your application has been approved.';
      case ApplicationStatus.rejected:
        return 'Your application has been rejected.';
    }
  }
}

extension ApplicationStatusColor on ApplicationStatus {
  Color get color {
    switch (this) {
      case ApplicationStatus.pending:
        return Colors.orange;
      case ApplicationStatus.underReview:
        return Colors.blue;
      case ApplicationStatus.approved:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
    }
  }
}

class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.applicationNumber,
    required this.applicantType,
    required this.semester,
    required this.fullNameEn,
    required this.nationality,
    required this.nationalId,
    required this.email,
    required this.mobile,
    required this.certificateTypeId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.fullNameAr,
    this.alternateMobile,
    this.certificateSpecializationId,
    this.schoolName,
    this.highSchoolGrade,
    this.facultyId,
    this.majorId,
    this.reviewComment,
    this.reviewedBy,
    this.reviewedAt,
    this.dateOfBirth,
    this.gender,
    this.guardianEmail,
  });

  final String id;
  final String applicationNumber;
  final String? userId;

  final String applicantType;
  final String semester;

  final String fullNameEn;
  final String? fullNameAr;

  final String nationality;
  final String nationalId;

  final String email;
  final String mobile;
  final String? alternateMobile;

  final int certificateTypeId;
  final int? certificateSpecializationId;

  final String? schoolName;
  final double? highSchoolGrade;

  final int? facultyId;
  final int? majorId;

  final ApplicationStatus status;

  final String? reviewComment;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  final DateTime? dateOfBirth;
  final String? gender;
  final String? guardianEmail;

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'],
      applicationNumber: json['application_number'],
      userId: json['user_id'],
      applicantType: json['applicant_type'],
      semester: json['semester'],
      fullNameEn: json['full_name_en'],
      fullNameAr: json['full_name_ar'],
      nationality: json['nationality'],
      nationalId: json['national_id'],
      email: json['email'],
      mobile: json['mobile'],
      alternateMobile: json['alternate_mobile'],
      certificateTypeId: json['certificate_type_id'],
      certificateSpecializationId: json['certificate_specialization_id'],
      schoolName: json['school_name'],
      highSchoolGrade: (json['high_school_grade'] as num?)?.toDouble(),
      facultyId: json['faculty_id'],
      majorId: json['major_id'],
      status: ApplicationStatus.fromString(json['status']?.toString() ?? ''),
      reviewComment: json['review_comment'],
      reviewedBy: json['profiles']?['full_name'],
      reviewedAt: json['reviewed_at'] == null
          ? null
          : DateTime.parse(json['reviewed_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth']),
      gender: json['gender'],
      guardianEmail: json['guardian_email'],
    );
  }
}
