import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';

import '../controllers/applicant_dashboard_controller.dart';

import '../models/application_document_model.dart';
import '../models/application_model.dart';
import 'dashboard_section_card.dart';

class UploadedDocumentsCard extends StatelessWidget {
  const UploadedDocumentsCard({
    super.key,
    required this.controller,
  });

  final ApplicantDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Uploaded Documents',
      child: Column(
        children: controller.documents
            .map(
              (doc) => _DocumentRow(
                document: doc,
                controller: controller,
                application: controller.application!,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.document,
    required this.controller,
    required this.application,
  });

  final ApplicationDocumentModel document;
  final ApplicantDashboardController controller;
  final ApplicationModel application;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            color: AppColors.primary,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              document.displayName,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _DocumentStatusBadge(status: application.status.label),
          SizedBox(width: 10.w),
          TextButton(
            onPressed: () async {
              final Uri url = Uri.parse(document.filePath);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                throw 'Could not launch $url';
              }
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}

class _DocumentStatusBadge extends StatelessWidget {
  const _DocumentStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: AppColors.success,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
