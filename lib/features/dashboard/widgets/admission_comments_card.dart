import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

import '../controllers/applicant_dashboard_controller.dart';

import '../models/application_model.dart';
import '../models/application_review_log_model.dart';
import 'dashboard_section_card.dart';

class AdmissionCommentsCard extends StatelessWidget {
  const AdmissionCommentsCard({
    super.key,
    required this.application,
    required this.controller,
  });

  final ApplicationModel application;
  final ApplicantDashboardController controller;
  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Admission Office Comments',
      child: controller.reviewLogs.isEmpty
          ? Column(
              children: [
                _LogsRow(
                  logs: ApplicationReviewLogModel(
                    id: '',
                    applicationId: '',
                    action: ApplicationReviewAction.submitted,
                    createdAt: DateTime.now(),
                    comment:
                        application.reviewComment ?? application.status.message,
                  ),
                ),
              ],
            )
          : Column(
              children: controller.reviewLogs
                  .map((logs) => _LogsRow(logs: logs))
                  .toList(),
            ),
    );
  }
}

class _LogsRow extends StatelessWidget {
  const _LogsRow({required this.logs});

  final ApplicationReviewLogModel logs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            logs.comment ?? "",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            logs.createdAt.toLocal().toString().split('.').first,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
