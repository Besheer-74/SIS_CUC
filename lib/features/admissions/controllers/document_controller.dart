import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../models/document_model.dart';

class DocumentController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final Map<String, PlatformFile> _pendingDocuments = {};
  final Map<String, DocumentModel> _uploadedDocuments = {};

  Map<String, PlatformFile> get pendingDocuments => _pendingDocuments;
  Map<String, DocumentModel> get uploadedDocuments => _uploadedDocuments;

  bool hasDocument(String documentType) {
    return _pendingDocuments.containsKey(documentType) ||
        _uploadedDocuments.containsKey(documentType);
  }

  PlatformFile? pendingDocument(String documentType) {
    return _pendingDocuments[documentType];
  }

  DocumentModel? uploadedDocument(String documentType) {
    return _uploadedDocuments[documentType];
  }

  Future<void> pickDocument(String documentType) async {
    _errorMessage = null;
    notifyListeners();

    final result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    final file = result?.files.single;
    if (file == null) {
      return;
    }

    if (file.bytes == null) {
      _errorMessage = 'Unable to read the selected file.';
      notifyListeners();
      return;
    }

    _pendingDocuments[documentType] = file;
    _uploadedDocuments.remove(documentType);
    notifyListeners();
  }

  void removeDocument(String documentType) {
    _pendingDocuments.remove(documentType);
    _uploadedDocuments.remove(documentType);
    notifyListeners();
  }

  Future<bool> uploadPendingDocuments({required String applicationId}) async {
    if (_pendingDocuments.isEmpty) {
      return true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final entries = _pendingDocuments.entries.toList();
      for (final entry in entries) {
        final document = await _uploadDocument(
          applicationId: applicationId,
          documentType: entry.key,
          file: entry.value,
        );

        _uploadedDocuments[entry.key] = document;
        _pendingDocuments.remove(entry.key);
      }

      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DocumentModel> _uploadDocument({
    required String applicationId,
    required String documentType,
    required PlatformFile file,
  }) async {
    final bytes = file.bytes;
    if (bytes == null) {
      throw Exception('Unable to read ${file.name}.');
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final filePath = SupabaseConfig.client.storage
        .from('application_documents')
        .getPublicUrl(fileName);
    final mimeType = _contentTypeFor(fileName);

    await SupabaseConfig.client.storage
        .from('application_documents')
        .uploadBinary(
          filePath,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: mimeType),
        );

    final response = await SupabaseConfig.client
        .from('application_documents')
        .insert({
          'application_id': applicationId,
          'document_type': documentType,
          'file_path': filePath,
          'file_name': file.name,
          'mime_type': mimeType,
        })
        .select()
        .single();

    return DocumentModel.fromJson(response);
  }

  String _contentTypeFor(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    return switch (extension) {
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      _ => 'application/octet-stream',
    };
  }

  void resetDocuments() {
    _pendingDocuments.clear();
    _uploadedDocuments.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
