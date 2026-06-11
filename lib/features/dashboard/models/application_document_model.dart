enum ApplicationDocumentType {
  nationalId,
  passport,
  guardianId,
  birthCertificate,
  highSchoolCertificate,
  personalPhoto,
  other;

  factory ApplicationDocumentType.fromString(String value) {
    switch (value) {
      case 'national_id':
        return ApplicationDocumentType.nationalId;
      case 'passport':
        return ApplicationDocumentType.passport;
      case 'guardian_id':
        return ApplicationDocumentType.guardianId;
      case 'birth_certificate':
        return ApplicationDocumentType.birthCertificate;
      case 'high_school_certificate':
        return ApplicationDocumentType.highSchoolCertificate;
      case 'personal_photo':
        return ApplicationDocumentType.personalPhoto;
      default:
        return ApplicationDocumentType.other;
    }
  }

  String get label {
    switch (this) {
      case ApplicationDocumentType.nationalId:
        return 'National ID';
      case ApplicationDocumentType.passport:
        return 'Passport';
      case ApplicationDocumentType.guardianId:
        return 'Guardian ID';
      case ApplicationDocumentType.birthCertificate:
        return 'Birth Certificate';
      case ApplicationDocumentType.highSchoolCertificate:
        return 'High School Certificate';
      case ApplicationDocumentType.personalPhoto:
        return 'Personal Photo';
      case ApplicationDocumentType.other:
        return 'Other';
    }
  }
}

class ApplicationDocumentModel {
  const ApplicationDocumentModel({
    required this.id,
    required this.applicationId,
    required this.documentType,
    required this.filePath,
    required this.createdAt,
    this.fileName,
    this.mimeType,
  });

  final String id;
  final String applicationId;
  final ApplicationDocumentType documentType;
  final String filePath;
  final DateTime createdAt;

  final String? fileName;
  final String? mimeType;

  factory ApplicationDocumentModel.fromJson(Map<String, dynamic> json) {
    return ApplicationDocumentModel(
      id: json['id'],
      applicationId: json['application_id'],
      documentType: ApplicationDocumentType.fromString(
        json['document_type']?.toString() ?? '',
      ),
      filePath: json['file_path'],
      fileName: json['file_name'],
      mimeType: json['mime_type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  String get displayName =>
      fileName?.trim().isNotEmpty == true ? fileName! : documentType.label;
}
