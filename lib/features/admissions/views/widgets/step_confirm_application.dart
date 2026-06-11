import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../controllers/application_controller.dart';
import '../../controllers/document_controller.dart';
import 'step_upload_documents.dart';

class StepConfirmApplication extends StatelessWidget {
  const StepConfirmApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ApplicationController, DocumentController>(
      builder: (context, applicationController, documentController, child) {
        final application = applicationController.application;
        final documents = StepUploadDocuments.requiredDocuments(context);

        return Column(
          children: [
            _SummarySection(
              title: 'Applicant',
              rows: [
                _SummaryRow('Full Name English', application.fullNameEn),
                _SummaryRow('Full Name Arabic', application.fullNameAr),
                _SummaryRow('Nationality', application.nationality),
                _SummaryRow('National ID / Passport', application.nationalId),
                _SummaryRow(
                  'Date of Birth',
                  application.dateOfBirth == null
                      ? null
                      : DateFormat(
                          'yyyy-MM-dd',
                        ).format(application.dateOfBirth!),
                ),
                _SummaryRow('Gender', application.gender),
              ],
            ),
            SizedBox(height: 16.h),
            _SummarySection(
              title: 'Contact',
              rows: [
                _SummaryRow('Personal Email', application.email),
                _SummaryRow('Guardian Email', application.guardianEmail),
                _SummaryRow('Phone Number', application.mobile),
                _SummaryRow(
                  'Alternate Phone Number',
                  application.alternateMobile,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _SummarySection(
              title: 'School and Admission',
              rows: [
                _SummaryRow('School Name', application.schoolName),
                _SummaryRow(
                  'Certificate Type',
                  applicationController.lookupNameFor(
                    'certificateType',
                    application.certificateTypeId,
                  ),
                ),
                _SummaryRow(
                  'Certificate Specialization',
                  applicationController.lookupNameFor(
                    'certificateSpecialization',
                    application.certificateSpecializationId,
                  ),
                ),
                _SummaryRow(
                  'High School Grade',
                  application.highSchoolGrade?.toString(),
                ),
                _SummaryRow(
                  'Faculty',
                  applicationController.lookupNameFor(
                    'faculty',
                    application.facultyId,
                  ),
                ),
                _SummaryRow(
                  'Major',
                  applicationController.lookupNameFor(
                    'major',
                    application.majorId,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _SummarySection(
              title: 'Documents',
              rows: documents
                  .map(
                    (document) => _SummaryRow(
                      document.title,
                      documentController.pendingDocument(document.type)?.name ??
                          documentController
                              .uploadedDocument(document.type)
                              ?.fileName,
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'Please review your application carefully before final submission.',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.title, required this.rows});

  final String title;
  final List<_SummaryRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          ...rows.map(
            (row) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 190.w,
                    child: Text(
                      row.label,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.value == null || row.value!.trim().isEmpty
                          ? '-'
                          : row.value!,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String? value;
}
