import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/admin_controller.dart';
import 'widgets/document_card.dart';

class StudentDetailsScreen extends StatefulWidget {
  final String studentId;
  final String applicationId;

  const StudentDetailsScreen({
    super.key,
    required this.studentId,
    required this.applicationId,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().getStudentDetails(widget.studentId);
      context.read<AdminController>().loadApplicationById(widget.applicationId);
    });
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
          'Student Details',
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
          return SingleChildScrollView(
            padding: EdgeInsets.all(32.w),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1000.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<Map<String, dynamic>>(
                      future: controller.getStudentDetails(widget.studentId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading student details',
                              style: TextStyle(color: AppColors.error),
                            ),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final student = snapshot.data!;
                        // applications is a single Map, not a List
                        final applicationData =
                            student['applications'] as Map<String, dynamic>?;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StudentInfoCard(
                              student: student,
                              applicationData: applicationData,
                            ),
                            SizedBox(height: 24.h),
                            _StudentAcademicCard(student: student),
                            SizedBox(height: 24.h),
                            if (applicationData != null)
                              _AdmissionDetailsCard(
                                applicationData: applicationData,
                                controller: controller,
                              ),
                            SizedBox(height: 24.h),
                            if (controller.documents.isNotEmpty)
                              DocumentsCard(documents: controller.documents),
                          ],
                        );
                      },
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

class _StudentInfoCard extends StatelessWidget {
  const _StudentInfoCard({
    required this.student,
    required this.applicationData,
  });

  final Map<String, dynamic> student;
  final Map<String, dynamic>? applicationData;

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
            'Student Information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 18.h),
          _DetailRow(
            label: 'Student Code',
            value: student['student_code'] ?? '-',
          ),
          if (applicationData != null) ...[
            _DetailRow(
              label: 'Name',
              value: applicationData!['full_name_en'] ?? '-',
            ),
            _DetailRow(
              label: 'Name (Arabic)',
              value: applicationData!['full_name_ar'] ?? '-',
            ),
            _DetailRow(
              label: 'Date of Birth',
              value: applicationData!['date_of_birth'] ?? '-',
            ),
            _DetailRow(
              label: 'Gender',
              value: applicationData!['gender'] ?? '-',
            ),
            _DetailRow(
              label: 'Nationality',
              value: applicationData!['nationality'] ?? '-',
            ),
            _DetailRow(
              label: 'national ID',
              value: applicationData!['national_id'] ?? '-',
            ),
            _DetailRow(label: 'Email', value: applicationData!['email'] ?? '-'),
            _DetailRow(
              label: 'mobile',
              value: applicationData!['mobile'] ?? '-',
            ),
            _DetailRow(
              label: 'Alternate Mobile',
              value: applicationData!['alternate_mobile'] ?? '-',
            ),
            _DetailRow(label: 'Status', value: student['status'] ?? '-'),
          ],
        ],
      ),
    );
  }
}

class _StudentAcademicCard extends StatelessWidget {
  const _StudentAcademicCard({required this.student});

  final Map<String, dynamic> student;

  @override
  Widget build(BuildContext context) {
    // faculties is a single Map (not a list)
    final faculty = student['faculties'] as Map<String, dynamic>?;
    final facultyName = faculty?['name'] ?? '-';
    final major = student['majors'] as Map<String, dynamic>?;
    final majorName = major?['name'] ?? '-';

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
            'Academic Information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 18.h),
          _DetailRow(label: 'Faculty', value: facultyName),
          _DetailRow(label: 'Major', value: majorName),
          _DetailRow(
            label: 'Current Semester',
            value: student['current_semester']?.toString() ?? '-',
          ),
          _DetailRow(label: 'Year', value: DateTime.now().year.toString()),
          _DetailRow(
            label: 'Max Credit Hours',
            value: student['max_credit_hours']?.toString() ?? '-',
          ),
        ],
      ),
    );
  }
}

class _AdmissionDetailsCard extends StatelessWidget {
  const _AdmissionDetailsCard({
    required this.applicationData,
    required this.controller,
  });

  final Map<String, dynamic> applicationData;
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
            'Original Admission Details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 18.h),
          _DetailRow(
            label: 'Application Number',
            value: applicationData['application_number'] ?? '-',
          ),
          _DetailRow(
            label: 'Application Status',
            value: applicationData['status'] ?? '-',
          ),
          _DetailRow(
            label: 'Certificate Type',
            value: controller.getCertificateTypeName(
              applicationData['certificate_type_id'],
            ),
          ),
          _DetailRow(
            label: 'Specialization',
            value: controller.getCertificateSpecializationName(
              applicationData['certificate_specialization_id'],
            ),
          ),
          _DetailRow(
            label: 'School Name',
            value: applicationData['school_name'] ?? '-',
          ),
          _DetailRow(
            label: 'High School Grade',
            value: applicationData['high_school_grade']?.toString() ?? '-',
          ),
        ],
      ),
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