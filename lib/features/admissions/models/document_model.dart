class DocumentModel {
  final String id;
  final String applicationId;
  final String documentType;
  final String filePath;
  final String? fileName;
  final String? mimeType;
  final DateTime? createdAt;

  DocumentModel({
    required this.id,
    required this.applicationId,
    required this.documentType,
    required this.filePath,
    this.fileName,
    this.mimeType,
    this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      applicationId: json['application_id'],
      documentType: json['document_type'],
      filePath: json['file_path'],
      fileName: json['file_name'],
      mimeType: json['mime_type'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}