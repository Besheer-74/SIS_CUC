import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

import '../controllers/applicant_dashboard_controller.dart';

import '../models/application_model.dart';
import '../models/application_review_log_model.dart';
import 'dashboard_section_card.dart';

class ApplicationTimelineCard extends StatelessWidget {
  const ApplicationTimelineCard({
    super.key,
    required this.controller,
    required this.application,
  });

  final ApplicationModel application;
  final ApplicantDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Review Progress',
      child: controller.reviewLogs.isEmpty
          ? Column(
              children: [
                _TimelinePlaceholder(
                  title: 'Application Submitted',
                  description: 'Your admission application has been submitted.',
                ),
                _TimelinePlaceholder(
                  title: 'Documents Uploaded',
                  description: 'Required documents are attached to your file.',
                ),
                _TimelinePlaceholder(
                  title: application.status == ApplicationStatus.pending
                      ? 'Pending Review'
                      : 'Under Review',
                  description: application.status.message,
                ),
              ],
            )
          : Column(
              children: controller.reviewLogs
                  .map((step) => _TimelineRow(step: step))
                  .toList(),
            ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step});

  final ApplicationReviewLogModel step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: Colors.white, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.action.label),
                Text(step.comment ?? step.action.label),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelinePlaceholder extends StatelessWidget {
  const _TimelinePlaceholder({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: Colors.white, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
