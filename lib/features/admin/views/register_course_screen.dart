import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/admin_controller.dart';
import '../controllers/course_controller.dart';
import '../models/course_model.dart';
import '../models/student_model.dart';

class RegistrationPanel extends StatefulWidget {
  final StudentModel student;
  final Map<String, dynamic>? studentDetails;
  final bool loadingDetails;
  final AdminController adminController;
  final CourseController courseController;
  final ValueChanged<StudentModel> onStudentUpdated;
  final VoidCallback onBack;

  const RegistrationPanel({
    super.key,
    required this.student,
    required this.studentDetails,
    required this.loadingDetails,
    required this.adminController,
    required this.courseController,
    required this.onStudentUpdated,
    required this.onBack,
  });

  @override
  State<RegistrationPanel> createState() => RegistrationPanelState();
}

class RegistrationPanelState extends State<RegistrationPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Back to Students',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        if (widget.loadingDetails)
          Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: const CircularProgressIndicator(),
            ),
          )
        else if (widget.studentDetails != null) ...[
          _StudentInfoPanel(
            student: widget.student,
            onStudentUpdated: widget.onStudentUpdated,
          ),
          SizedBox(height: 24.h),
          _CoursesPanel(
            student: widget.student,
            adminController: widget.adminController,
            courseController: widget.courseController,
          ),
          SizedBox(height: 24.h),
          _SummaryPanel(courseController: widget.courseController),
        ] else
          EmptyState(),
      ],
    );
  }
}

class _StudentInfoPanel extends StatefulWidget {
  final StudentModel student;
  final ValueChanged<StudentModel> onStudentUpdated;

  const _StudentInfoPanel({
    required this.student,
    required this.onStudentUpdated,
  });

  @override
  State<_StudentInfoPanel> createState() => _StudentInfoPanelState();
}

class _StudentInfoPanelState extends State<_StudentInfoPanel> {
  late final TextEditingController _semesterController;
  late final TextEditingController _maxCreditsController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _semesterController = TextEditingController(
      text: widget.student.currentSemester.toString(),
    );
    _maxCreditsController = TextEditingController(
      text: widget.student.maxCreditHours.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _StudentInfoPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.student.id != widget.student.id ||
        oldWidget.student.currentSemester != widget.student.currentSemester ||
        oldWidget.student.maxCreditHours != widget.student.maxCreditHours) {
      _semesterController.text = widget.student.currentSemester.toString();
      _maxCreditsController.text = widget.student.maxCreditHours.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AdminController>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
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
          Row(
            children: [
              Text(
                'Student Information',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_isEditing)
                _PanelActionButton(
                  label: 'Save',
                  icon: Icons.save_outlined,
                  onTap: () => _save(context),
                )
              else
                _PanelActionButton(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  onTap: () => setState(() => _isEditing = true),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          if (controller.successMessage != null) ...[
            _InlineMessage(
              message: controller.successMessage!,
              color: AppColors.success,
            ),
            SizedBox(height: 14.h),
          ],
          if (controller.errorMessage != null) ...[
            _InlineMessage(
              message: controller.errorMessage!,
              color: AppColors.error,
            ),
            SizedBox(height: 14.h),
          ],
          Wrap(
            spacing: 32.w,
            runSpacing: 16.h,
            children: [
              _InfoField(
                label: 'Student Code',
                value: widget.student.studentCode,
              ),
              _InfoField(
                label: 'Faculty',
                value: controller.getFacultyName(widget.student.facultyId),
              ),
              _InfoField(
                label: 'Major',
                value: controller.getMajorName(widget.student.majorId),
              ),
              if (_isEditing) ...[
                _EditableInfoField(
                  label: 'Current Semester',
                  controller: _semesterController,
                ),
                _EditableInfoField(
                  label: 'Max Credit Hours',
                  controller: _maxCreditsController,
                ),
              ] else ...[
                _InfoField(
                  label: 'Current Semester',
                  value: widget.student.currentSemester.toString(),
                ),
                _InfoField(
                  label: 'Max Credit Hours',
                  value: widget.student.maxCreditHours.toString(),
                ),
              ],
              _InfoField(label: 'Status', value: widget.student.status),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final semester = int.tryParse(_semesterController.text.trim());
    final maxCredits = int.tryParse(_maxCreditsController.text.trim());

    if (semester == null ||
        semester < 1 ||
        maxCredits == null ||
        maxCredits < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid positive numbers.')),
      );
      return;
    }

    final updatedStudent = await context
        .read<AdminController>()
        .updateStudentRegistrationSettings(
          studentId: widget.student.id,
          currentSemester: semester,
          maxCreditHours: maxCredits,
        );

    if (!context.mounted || updatedStudent == null) {
      return;
    }

    widget.onStudentUpdated(updatedStudent);
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student registration settings updated.')),
    );
  }

  @override
  void dispose() {
    _semesterController.dispose();
    _maxCreditsController.dispose();
    super.dispose();
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EditableInfoField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _EditableInfoField({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180.w,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
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
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
        ),
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PanelActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PanelActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.primary),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;
  final Color color;

  const _InlineMessage({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CoursesPanel extends StatefulWidget {
  final StudentModel student;
  final AdminController adminController;
  final CourseController courseController;

  const _CoursesPanel({
    required this.student,
    required this.adminController,
    required this.courseController,
  });

  @override
  State<_CoursesPanel> createState() => _CoursesPanelState();
}

class _CoursesPanelState extends State<_CoursesPanel> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final courses = widget.courseController.facultyCourses;

    if (courses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Center(
          child: Text(
            'No courses available for this faculty',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Text(
                'Available Courses',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: DataTable(
                  columnSpacing: 20.w,
                  headingRowColor: WidgetStatePropertyAll(
                    AppColors.surfaceMuted,
                  ),
                  border: TableBorder(
                    horizontalInside: BorderSide(color: AppColors.borderLight),
                    bottom: BorderSide(color: AppColors.borderLight),
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Course Code',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Course Name',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Credit Hours',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Prerequisites',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Action',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  rows: courses
                      .map(
                        (course) => DataRow(
                          cells: [
                            DataCell(
                              Text(
                                course.code,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                course.name,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                course.creditHours.toString(),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            DataCell(
                              _PrerequisiteCell(
                                courseId: course.id,
                                courseController: widget.courseController,
                              ),
                            ),
                            DataCell(
                              _CourseStatusBadge(
                                isEnabled: widget.courseController
                                    .isCourseEnabled(course.id),
                              ),
                            ),
                            DataCell(
                              _CourseActionButton(
                                course: course,
                                student: widget.student,
                                isEnabled: widget.courseController
                                    .isCourseEnabled(course.id),
                                onTap: () async {
                                  setState(() => _isUpdating = true);
                                  if (widget.courseController.isCourseEnabled(
                                    course.id,
                                  )) {
                                    await widget.courseController.disableCourse(
                                      studentId: widget.student.id,
                                      courseId: course.id,
                                    );
                                  } else {
                                    await widget.courseController.enableCourse(
                                      studentId: widget.student.id,
                                      courseId: course.id,
                                      semester: widget.student.currentSemester,
                                    );
                                  }
                                  setState(() => _isUpdating = false);
                                },
                                isUpdating: _isUpdating,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class _CourseStatusBadge extends StatelessWidget {
  final bool isEnabled;

  const _CourseStatusBadge({required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isEnabled
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: isEnabled
              ? Colors.green.withValues(alpha: 0.35)
              : Colors.red.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        isEnabled ? 'Enabled' : 'Disabled',
        style: TextStyle(
          color: isEnabled ? Colors.green : Colors.red,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CourseActionButton extends StatelessWidget {
  final CourseModel course;
  final StudentModel student;
  final bool isEnabled;
  final VoidCallback onTap;
  final bool isUpdating;

  const _CourseActionButton({
    required this.course,
    required this.student,
    required this.isEnabled,
    required this.onTap,
    required this.isUpdating,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUpdating ? null : onTap,
      child: MouseRegion(
        cursor: isUpdating
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isEnabled
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(
              color: isEnabled
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.green.withValues(alpha: 0.3),
            ),
          ),
          child: isUpdating
              ? SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      isEnabled ? Colors.red : Colors.green,
                    ),
                  ),
                )
              : Text(
                  isEnabled ? 'Disable' : 'Enable',
                  style: TextStyle(
                    color: isEnabled ? Colors.red : Colors.green,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

class _PrerequisiteCell extends StatelessWidget {
  final int courseId;
  final CourseController courseController;

  const _PrerequisiteCell({
    required this.courseId,
    required this.courseController,
  });

  @override
  Widget build(BuildContext context) {
    final prerequisite = courseController.coursePrerequisites[courseId];

    if (prerequisite == null) {
      return Text(
        'None',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
      );
    }

    final prereqCourseName = courseController.getCourseName(
      prerequisite.prerequisiteCourseId,
    );

    return Tooltip(
      message: 'Prerequisite: $prereqCourseName',
      child: Text(
        prereqCourseName,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final CourseController courseController;

  const _SummaryPanel({required this.courseController});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16.w,
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total Courses',
            value: courseController.totalFacultyCourses.toString(),
            icon: Icons.school_rounded,
            color: Colors.blue,
          ),
        ),
        Expanded(
          child: _SummaryCard(
            title: 'Enabled Courses',
            value: courseController.enabledCoursesCount.toString(),
            icon: Icons.check_circle_rounded,
            color: Colors.green,
          ),
        ),
        Expanded(
          child: _SummaryCard(
            title: 'Disabled Courses',
            value: courseController.disabledCoursesCount.toString(),
            icon: Icons.cancel_rounded,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              Icon(icon, color: color, size: 20.sp),
              const Spacer(),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 48.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              'No data available',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Select a student to manage their course registration',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }
}
