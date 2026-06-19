import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../controllers/applicant_dashboard_controller.dart';
import '../models/application_model.dart';
import '../widgets/applicant_status_badge.dart';
import '../widgets/dashboard_section_card.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/dashboard_two_column.dart';
import '../widgets/uploaded_documents_card.dart';

class MyApplicationScreen extends StatefulWidget {
  const MyApplicationScreen({super.key});

  @override
  State<MyApplicationScreen> createState() => _MyApplicationScreenState();
}

class _MyApplicationScreenState extends State<MyApplicationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicantDashboardController>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          const ApplicantSidebar(currentRoute: AppRoutes.myApplication),
          Expanded(
            child: Consumer<ApplicantDashboardController>(
              builder: (context, controller, child) {
                final application = controller.application;

                return Column(
                  children: [
                    const _TopBar(),
                    if (controller.isLoading)
                      const LinearProgressIndicator(minHeight: 2),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(32.w),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 1180.w),
                            child: application == null
                                ? _EmptyOrLoading(controller: controller)
                                : _ApplicationHistoryContent(
                                    controller: controller,
                                    application: application,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82.h,
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Text(
            'My Application',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Application History',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
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

class _EmptyOrLoading extends StatelessWidget {
  const _EmptyOrLoading({required this.controller});

  final ApplicantDashboardController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return Padding(
        padding: EdgeInsets.all(48.w),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return _MessageCard(
      message: controller.errorMessage ?? 'No application record was found.',
      color: AppColors.warning,
    );
  }
}

class _ApplicationHistoryContent extends StatelessWidget {
  const _ApplicationHistoryContent({
    required this.controller,
    required this.application,
  });

  final ApplicantDashboardController controller;
  final ApplicationModel application;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageHeader(application: application),
        SizedBox(height: 24.h),
        DashboardTwoColumn(
          left: _ApplicationInfoCard(
            controller: controller,
            application: application,
          ),
          right: _ReviewInfoCard(application: application),
        ),
        SizedBox(height: 24.h),
        DashboardTwoColumn(
          left: _TimelineCard(application: application),
          right: UploadedDocumentsCard(controller: controller),
        ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.application});

  final ApplicationModel application;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Application History',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Review the admission application record that resulted in your student account.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        ApplicantStatusBadge(status: application.status, compact: true),
      ],
    );
  }
}

class _ApplicationInfoCard extends StatelessWidget {
  const _ApplicationInfoCard({
    required this.controller,
    required this.application,
  });

  final ApplicantDashboardController controller;
  final ApplicationModel application;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Application Information',
      child: Column(
        children: [
          _ReadOnlyRow(
            label: 'Application Number',
            value: application.applicationNumber,
          ),
          _ReadOnlyRow(
            label: 'Submission Date',
            value: _formatDate(application.createdAt),
          ),
          _ReadOnlyRow(label: 'Applicant Name', value: application.fullNameEn),
          _ReadOnlyRow(label: 'Faculty', value: controller.facultyName),
          _ReadOnlyRow(label: 'Major', value: controller.majorName),
          _ReadOnlyRow(
            label: 'Certificate Type',
            value: controller.certificateTypeName,
          ),
          _ReadOnlyRow(label: 'Application Status', value: application.status.label),
        ],
      ),
    );
  }
}

class _ReviewInfoCard extends StatelessWidget {
  const _ReviewInfoCard({required this.application});

  final ApplicationModel application;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Review Information',
      child: Column(
        children: [
          _ReadOnlyRow(
            label: 'Review Comment',
            value: application.reviewComment ?? 'No review comment recorded.',
          ),
          _ReadOnlyRow(
            label: 'Reviewed At',
            value: application.reviewedAt == null
                ? '-'
                : _formatDateTime(application.reviewedAt!),
          ),
          _ReadOnlyRow(label: 'Reviewed By', value: application.reviewedBy ?? '-'),
          if (application.status == ApplicationStatus.approved)
            _MessageCard(
              message: 'Approved application record',
              color: AppColors.success,
            ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.application});

  final ApplicationModel application;

  @override
  Widget build(BuildContext context) {
    final finalStep = application.status == ApplicationStatus.rejected
        ? 'Rejected'
        : 'Approved';

    return DashboardSectionCard(
      title: 'Review Timeline',
      child: Column(
        children: [
          _TimelineRow(title: 'Submitted', isComplete: true),
          _TimelineRow(
            title: 'Under Review',
            isComplete: application.status != ApplicationStatus.pending,
          ),
          _TimelineRow(
            title: finalStep,
            isComplete:
                application.status == ApplicationStatus.approved ||
                application.status == ApplicationStatus.rejected,
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.title, required this.isComplete});

  final String title;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: isComplete ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isComplete ? AppColors.primary : AppColors.borderLight,
              ),
            ),
            child: Icon(
              isComplete ? Icons.check_rounded : Icons.circle_outlined,
              color: isComplete ? Colors.white : AppColors.textSecondary,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150.w,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return date.toLocal().toString().split(' ').first;
}

String _formatDateTime(DateTime date) {
  return date.toLocal().toString().split('.').first;
}
