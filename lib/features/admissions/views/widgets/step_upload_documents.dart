import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../controllers/application_controller.dart';
import '../../controllers/document_controller.dart';
import 'lookup_status_message.dart';

class RequiredDocumentDefinition {
  const RequiredDocumentDefinition({
    required this.type,
    required this.title,
    required this.description,
  });

  final String type;
  final String title;
  final String description;
}

class StepUploadDocuments extends StatelessWidget {
  const StepUploadDocuments({super.key});

  static bool validateRequiredDocuments(BuildContext context) {
    final missingDocuments = requiredDocuments(context)
        .where(
          (document) =>
              !context.read<DocumentController>().hasDocument(document.type),
        )
        .toList();

    if (missingDocuments.isEmpty) {
      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please upload: ${missingDocuments.map((doc) => doc.title).join(', ')}.',
        ),
      ),
    );

    return false;
  }

  static List<RequiredDocumentDefinition> requiredDocuments(
    BuildContext context,
  ) {
    final nationality = context
        .read<ApplicationController>()
        .application
        .nationality;
    final identityDocument = nationality == 'Egypt'
        ? const RequiredDocumentDefinition(
            type: 'national_id',
            title: 'National ID',
            description: 'Upload a clear copy of the applicant national ID.',
          )
        : const RequiredDocumentDefinition(
            type: 'passport',
            title: 'Passport',
            description: 'Upload a clear copy of the applicant passport.',
          );

    return [
      const RequiredDocumentDefinition(
        type: 'birth_certificate',
        title: 'Birth Certificate',
        description: 'Accepted formats: PDF, JPG, JPEG, or PNG.',
      ),
      identityDocument,
      const RequiredDocumentDefinition(
        type: 'guardian_id',
        title: 'Guardian ID',
        description: 'Upload guardian national ID or passport.',
      ),
      const RequiredDocumentDefinition(
        type: 'high_school_certificate',
        title: 'High School Certificate',
        description: 'Upload the official high school certificate.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final documents = requiredDocuments(context);

    return Consumer<DocumentController>(
      builder: (context, controller, child) {
        return Column(
          children: [
            if (controller.errorMessage != null) ...[
              LookupStatusMessage(message: controller.errorMessage!),
              SizedBox(height: 16.h),
            ],
            ...documents.expand(
              (document) => [
                _UploadDocumentCard(
                  definition: document,
                  pendingFile: controller.pendingDocument(document.type),
                  uploadedFileName: controller
                      .uploadedDocument(document.type)
                      ?.fileName,
                  isLoading: controller.isLoading,
                  onPick: () => controller.pickDocument(document.type),
                  onRemove: () => controller.removeDocument(document.type),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _UploadDocumentCard extends StatelessWidget {
  const _UploadDocumentCard({
    required this.definition,
    required this.onPick,
    required this.onRemove,
    this.pendingFile,
    this.uploadedFileName,
    this.isLoading = false,
  });

  final RequiredDocumentDefinition definition;
  final PlatformFile? pendingFile;
  final String? uploadedFileName;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final bool isLoading;

  bool get _hasFile => pendingFile != null || uploadedFileName != null;

  @override
  Widget build(BuildContext context) {
    final fileName = pendingFile?.name ?? uploadedFileName;
    final fileSize = pendingFile == null
        ? null
        : _formatFileSize(pendingFile!.size);

    return InkWell(
      onTap: isLoading ? null : onPick,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: _hasFile
              ? AppColors.primary.withValues(alpha: 0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: _hasFile ? AppColors.primary : AppColors.borderLight,
            width: _hasFile ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                _hasFile
                    ? Icons.description_outlined
                    : Icons.cloud_upload_outlined,
                color: AppColors.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: definition.title),
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _hasFile
                        ? [fileName, fileSize].whereType<String>().join(' • ')
                        : definition.description,
                    style: TextStyle(
                      color: _hasFile
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 13.sp,
                      fontWeight: _hasFile ? FontWeight.w500 : FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                  if (!_hasFile) ...[
                    SizedBox(height: 8.h),
                    Text(
                      'Drag and drop appearance • Click to browse files',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 12.w),
            if (_hasFile) ...[
              TextButton(
                onPressed: isLoading ? null : onPick,
                child: const Text('Replace'),
              ),
              IconButton(
                tooltip: 'Remove',
                onPressed: isLoading ? null : onRemove,
                icon: const Icon(Icons.close_rounded),
              ),
            ] else ...[
              Icon(
                Icons.attach_file_rounded,
                color: AppColors.primary,
                size: 22.sp,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    final kb = bytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }

    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}
