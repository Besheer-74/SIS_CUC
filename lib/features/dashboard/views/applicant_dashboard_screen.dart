import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';

import '../controllers/applicant_dashboard_controller.dart';

import '../models/application_model.dart';

import '../widgets/admission_comments_card.dart';
import '../widgets/applicant_status_badge.dart';
import '../widgets/application_timeline_card.dart';
import '../widgets/approved_applicant_card.dart';
import '../widgets/dashboard_info_card.dart';
import '../widgets/dashboard_section_card.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/dashboard_two_column.dart';
import '../widgets/uploaded_documents_card.dart';

class ApplicantDashboard extends StatefulWidget {
  const ApplicantDashboard({super.key});

  @override
  State<ApplicantDashboard> createState() => _ApplicantDashboardState();
}

class _ApplicantDashboardState extends State<ApplicantDashboard> {
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
          const ApplicantSidebar(),
          Expanded(
            child: Consumer<ApplicantDashboardController>(
              builder: (context, controller, child) {
                final application = controller.application;
                if (application == null) {
                  return Column(
                    children: [
                      const _ApplicantTopBar(),
                      if (controller.isLoading)
                        const LinearProgressIndicator(minHeight: 2),
                      Expanded(
                        child: Center(
                          child: controller.errorMessage == null
                              ? const CircularProgressIndicator()
                              : _DashboardErrorBanner(
                                  message: controller.errorMessage!,
                                ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    _ApplicantTopBar(application: application),
                    if (controller.isLoading)
                      const LinearProgressIndicator(minHeight: 2),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(32.w),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 1180.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (controller.errorMessage != null) ...[
                                  _DashboardErrorBanner(
                                    message: controller.errorMessage!,
                                  ),
                                  SizedBox(height: 20.h),
                                ],
                                if (application.status ==
                                    ApplicationStatus.approved)
                                  _ApprovedStudentDashboard(
                                    controller: controller,
                                    application: application,
                                  )
                                else
                                  _AdmissionTrackingDashboard(
                                    controller: controller,
                                    application: application,
                                  ),
                              ],
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

class _ApplicantTopBar extends StatelessWidget {
  const _ApplicantTopBar({this.application});

  final ApplicationModel? application;

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
            'Applicant Dashboard',
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
                  Icons.person_outline_rounded,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  application?.fullNameEn ?? 'Student Portal',
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

class _AdmissionTrackingDashboard extends StatelessWidget {
  const _AdmissionTrackingDashboard({
    required this.controller,
    required this.application,
  });

  final ApplicantDashboardController controller;
  final ApplicationModel application;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DashboardHeader(application: application),
        SizedBox(height: 24.h),
        _MetricGrid(controller: controller, application: application),
        SizedBox(height: 24.h),
        _StatusMessageCard(controller: controller, application: application),
        SizedBox(height: 24.h),
        DashboardTwoColumn(
          left: ApplicationTimelineCard(
            controller: controller,
            application: application,
          ),
          right: _ApplicationDetailsCard(
            controller: controller,
            application: application,
          ),
        ),
        SizedBox(height: 24.h),
        DashboardTwoColumn(
          left: UploadedDocumentsCard(controller: controller),
          right: AdmissionCommentsCard(
            controller: controller,
            application: application,
          ),
        ),
      ],
    );
  }
}

class _ApprovedStudentDashboard extends StatelessWidget {
  const _ApprovedStudentDashboard({
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
        _StudentDashboardHeader(application: application),
        SizedBox(height: 24.h),
        _StudentMetricGrid(controller: controller),
        SizedBox(height: 24.h),
        DashboardTwoColumn(
          left: _AcademicSummaryCard(controller: controller),
          right: _QuickActionsCard(),
        ),
        SizedBox(height: 24.h),
        _AnnouncementsCard(),
      ],
    );
  }
}

class _StudentDashboardHeader extends StatelessWidget {
  const _StudentDashboardHeader({required this.application});

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
                'Student Overview',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'View your academic summary, registration status, schedule, and university updates.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        ApplicantStatusBadge(status: application.status),
      ],
    );
  }
}

class _StudentMetricGrid extends StatelessWidget {
  const _StudentMetricGrid({required this.controller});

  final ApplicantDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final student = controller.student;
    final cards = [
      DashboardInfoCard(
        title: 'Student Code',
        value: student?.studentCode ?? '-',
        icon: Icons.badge_outlined,
      ),
      DashboardInfoCard(
        title: 'Current Semester',
        value: student?.currentSemester.toString() ?? '-',
        icon: Icons.calendar_month_outlined,
      ),
      DashboardInfoCard(
        title: 'Registered Courses Count',
        value: controller.registeredCoursesCount.toString(),
        icon: Icons.library_books_outlined,
      ),
      DashboardInfoCard(
        title: 'Credit Hours Used / Maximum',
        value:
            '${controller.registeredCreditHours} / ${controller.maxCreditHours}',
        icon: Icons.timelapse_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 16.w;
        final cardWidth = (constraints.maxWidth - spacing * 3) / 4;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (card) => SizedBox(
                  width: cardWidth.clamp(230.w, constraints.maxWidth),
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _AcademicSummaryCard extends StatelessWidget {
  const _AcademicSummaryCard({required this.controller});

  final ApplicantDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Academic Summary',
      child: Column(
        children: [
          _ReadOnlyRow(label: 'Faculty', value: controller.facultyName),
          _ReadOnlyRow(label: 'Major', value: controller.majorName),
          _ReadOnlyRow(
            label: 'Student Status',
            value: controller.student?.status ?? '-',
          ),
          _ReadOnlyRow(
            label: 'Remaining Credit Hours',
            value: controller.remainingCreditHours.toString(),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Quick Actions',
      child: Column(
        children: [
          _QuickActionRow(
            icon: Icons.app_registration_rounded,
            title: 'Course Registration',
            onTap: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.courseRegistration,
            ),
          ),
          _QuickActionRow(
            icon: Icons.calendar_month_outlined,
            title: 'My Schedule',
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.mySchedule),
          ),
          _QuickActionRow(
            icon: Icons.mark_email_unread_outlined,
            title: 'Messages',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Announcements',
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(
          'No announcements available at the moment.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DashboardErrorBanner extends StatelessWidget {
  const _DashboardErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.application});

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
                'Admission Application',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Track your submitted application, documents, review progress, and admission office comments.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        ApplicantStatusBadge(status: application.status),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.application, required this.controller});

  final ApplicationModel application;
  final ApplicantDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final cards = [
      DashboardInfoCard(
        title: 'Application Number',
        value: application.applicationNumber,
        icon: Icons.confirmation_number_outlined,
      ),
      DashboardInfoCard(
        title: 'Application Status',
        value: application.status.label,
        icon: Icons.fact_check_outlined,
        trailing: ApplicantStatusBadge(
          status: application.status,
          compact: true,
        ),
      ),
      DashboardInfoCard(
        title: 'Selected Faculty',
        value: controller.facultyName,
        icon: Icons.account_balance_outlined,
      ),
      DashboardInfoCard(
        title: 'Submission Date',
        value: application.createdAt.toLocal().toString().split(' ').first,
        icon: Icons.calendar_month_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 16.w;
        final cardWidth = (constraints.maxWidth - spacing * 3) / 4;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (card) => SizedBox(
                  width: cardWidth.clamp(230.w, constraints.maxWidth),
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatusMessageCard extends StatelessWidget {
  const _StatusMessageCard({
    required this.controller,
    required this.application,
  });

  final ApplicationModel application;
  final ApplicantDashboardController controller;

  @override
  Widget build(BuildContext context) {
    if (application.status == ApplicationStatus.approved) {
      return ApprovedApplicantCard(
        controller: controller,
        application: application,
      );
    }

    final isRejected = application.status == ApplicationStatus.rejected;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isRejected
            ? AppColors.error.withValues(alpha: 0.08)
            : AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isRejected
              ? AppColors.error.withValues(alpha: 0.24)
              : AppColors.accent.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isRejected
                ? Icons.error_outline_rounded
                : Icons.info_outline_rounded,
            color: isRejected ? AppColors.error : AppColors.primary,
            size: 22.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              application.reviewComment ?? application.status.message,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationDetailsCard extends StatelessWidget {
  const _ApplicationDetailsCard({
    required this.controller,
    required this.application,
  });

  final ApplicationModel application;
  final ApplicantDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Submitted Details',
      child: Column(
        children: [
          _ReadOnlyRow(label: 'Applicant Name', value: application.fullNameEn),
          _ReadOnlyRow(
            label: 'Certificate Type',
            value: controller.certificateTypeName,
          ),
          _ReadOnlyRow(
            label: 'Specialization',
            value: controller.specializationName,
          ),
          _ReadOnlyRow(
            label: 'Selected Faculty',
            value: controller.facultyName,
          ),
          _ReadOnlyRow(label: 'Email', value: application.email),
          _ReadOnlyRow(label: 'Mobile', value: application.mobile),
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
