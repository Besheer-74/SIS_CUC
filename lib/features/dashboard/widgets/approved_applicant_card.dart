import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

import '../controllers/applicant_dashboard_controller.dart';

import '../models/application_model.dart';

class ApprovedApplicantCard extends StatelessWidget {
  const ApprovedApplicantCard({
    super.key,
    required this.controller,
    required this.application,
  });

  final ApplicationModel application;
  final ApplicantDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: AppColors.success, size: 34.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Congratulations!',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your application has been approved.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 18.w,
                  runSpacing: 8.h,
                  children: [
                    _ApprovedDetail(
                      label: 'Student ID',
                      value: application.applicationNumber,
                    ),
                    _ApprovedDetail(
                      label: 'Faculty',
                      value: controller.facultyName,
                    ),
                    _ApprovedDetail(
                      label: 'Major',
                      value: controller.majorName,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 18.w),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.login_rounded),
            label: const Text('Enter Student Portal'),
          ),
        ],
      ),
    );
  }
}

class _ApprovedDetail extends StatelessWidget {
  const _ApprovedDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13.sp,
          height: 1.4,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
extension ApplicationStatusColor on ApplicationStatus {
  Color get color {
    return switch (this) {
      ApplicationStatus.pending => AppColors.accent,
      ApplicationStatus.underReview => AppColors.primary,
      ApplicationStatus.approved => AppColors.success,
      ApplicationStatus.rejected => AppColors.error,
    };
  }
}
