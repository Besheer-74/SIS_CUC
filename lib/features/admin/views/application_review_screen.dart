import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../dashboard/models/application_model.dart';
import '../../dashboard/widgets/applicant_status_badge.dart';
import '../controllers/admin_controller.dart';
import 'widgets/document_card.dart';

class ApplicationReviewScreen extends StatefulWidget {
  final String applicationId;

  const ApplicationReviewScreen({super.key, required this.applicationId});

  @override
  State<ApplicationReviewScreen> createState() =>
      _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  late TextEditingController _reviewCommentController;
  late AdminController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<AdminController>();
    _reviewCommentController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadApplicationById(widget.applicationId);
      _reviewCommentController.text =
          _controller.currentApplication?.reviewComment ?? '';
    });
  }

  @override
  void dispose() {
    _reviewCommentController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(ApplicationStatus newStatus) async {
    await _controller.updateApplicationStatus(
      applicationId: widget.applicationId,
      newStatus: newStatus,
      reviewComment: _reviewCommentController.text,
    );

    if (!mounted) return;

    String message = '';
    if (newStatus == ApplicationStatus.underReview) {
      message = 'Application moved to Under Review';
    } else if (newStatus == ApplicationStatus.approved) {
      message = 'Application Approved';
    } else if (newStatus == ApplicationStatus.rejected) {
      message = 'Application Rejected';
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    if (newStatus == ApplicationStatus.approved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Student Record Created')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Application Review',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(height: 1.h, color: AppColors.borderLight),
        ),
      ),
      body: Consumer<AdminController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.currentApplication == null) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            );
          }

          if (controller.errorMessage != null &&
              controller.currentApplication == null) {
            return Center(
              child: Text(
                controller.errorMessage ?? 'Error loading application',
                style: TextStyle(color: AppColors.error, fontSize: 14.sp),
              ),
            );
          }

          final app = controller.currentApplication;
          if (app == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(32.w),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1000.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ApplicationHeaderCard(app: app),
                    SizedBox(height: 24.h),
                    _ApplicantDetailsCard(app: app, controller: controller),
                    SizedBox(height: 24.h),
                    _AcademicDetailsCard(app: app, controller: controller),
                    SizedBox(height: 24.h),
                    if (controller.documents.isNotEmpty)
                      DocumentsCard(documents: controller.documents),
                    if (controller.documents.isNotEmpty) SizedBox(height: 24.h),
                    _ReviewCommentCard(controller: _reviewCommentController),
                    SizedBox(height: 24.h),
                    _ActionButtonsRow(
                      app: app,
                      onStartReview: () =>
                          _updateStatus(ApplicationStatus.underReview),
                      onApprove: () =>
                          _updateStatus(ApplicationStatus.approved),
                      onReject: () => _updateStatus(ApplicationStatus.rejected),
                      isLoading: controller.isLoading,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ApplicationHeaderCard extends StatelessWidget {
  const _ApplicationHeaderCard({required this.app});

  final ApplicationModel app;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 22.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Application Number',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  app.applicationNumber,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Status',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              ApplicantStatusBadge(status: app.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApplicantDetailsCard extends StatelessWidget {
  const _ApplicantDetailsCard({required this.app, required this.controller});

  final ApplicationModel app;
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 22.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applicant Information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 18.h),
          _DetailRow(label: 'Full Name', value: app.fullNameEn),
          _DetailRow(label: 'Full Name Ar', value: app.fullNameAr ?? '-'),
          _DetailRow(label: 'Nationality', value: app.nationality),
          _DetailRow(label: 'National ID', value: app.nationalId),
          _DetailRow(label: 'Gender', value: app.gender ?? '-'),
          _DetailRow(
            label: 'Date of Birth',
            value: app.dateOfBirth != null
                ? app.dateOfBirth!.toLocal().toString().split(' ').first
                : '-',
          ),
          _DetailRow(label: 'Mobile', value: app.mobile),
          _DetailRow(
            label: 'Alternate Mobile',
            value: app.alternateMobile ?? '-',
          ),
          _DetailRow(label: 'Email', value: app.email),
          _DetailRow(label: 'Guardian Email', value: app.guardianEmail ?? '-'),
          _DetailRow(label: 'Semester', value: app.semester),
          _DetailRow(
            label: 'Submission Date',
            value: app.createdAt.toLocal().toString().split(' ').first,
          ),
        ],
      ),
    );
  }
}

class _AcademicDetailsCard extends StatelessWidget {
  const _AcademicDetailsCard({required this.app, required this.controller});

  final ApplicationModel app;
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 22.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Academic Details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 18.h),
          _DetailRow(
            label: 'Certificate Type',
            value: controller.getCertificateTypeName(app.certificateTypeId),
          ),
          _DetailRow(
            label: 'Specialization',
            value: controller.getCertificateSpecializationName(
              app.certificateSpecializationId,
            ),
          ),
          _DetailRow(label: 'School Name', value: app.schoolName ?? '-'),
          _DetailRow(
            label: 'High School Grade',
            value: app.highSchoolGrade?.toString() ?? '-',
          ),
          _DetailRow(
            label: 'Selected Faculty',
            value: controller.getFacultyName(app.facultyId),
          ),
          _DetailRow(
            label: 'Selected Major',
            value: controller.getMajorName(app.majorId),
          ),
        ],
      ),
    );
  }
}

class _ReviewCommentCard extends StatelessWidget {
  const _ReviewCommentCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 22.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Comment',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Add your review comment here...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(14.w),
            ),
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow({
    required this.app,
    required this.onStartReview,
    required this.onApprove,
    required this.onReject,
    required this.isLoading,
  });

  final ApplicationModel app;
  final VoidCallback onStartReview;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final canStartReview = app.status == ApplicationStatus.pending;
    final canApproveReject =
        app.status == ApplicationStatus.pending ||
        app.status == ApplicationStatus.underReview;

    return Row(
      children: [
        if (canStartReview) ...[
          ElevatedButton(
            onPressed: isLoading ? null : onStartReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              disabledBackgroundColor: AppColors.disabledBackground,
            ),
            child: Text(
              'Start Review',
              style: TextStyle(
                color: isLoading ? AppColors.textSecondary : Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
        if (canApproveReject) ...[
          ElevatedButton(
            onPressed: isLoading ? null : onApprove,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              disabledBackgroundColor: AppColors.disabledBackground,
            ),
            child: Text(
              'Approve',
              style: TextStyle(
                color: isLoading ? AppColors.textSecondary : Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: isLoading ? null : onReject,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              disabledBackgroundColor: AppColors.disabledBackground,
            ),
            child: Text(
              'Reject',
              style: TextStyle(
                color: isLoading ? AppColors.textSecondary : Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
