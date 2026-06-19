import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../dashboard/widgets/dashboard_info_card.dart';
import '../../dashboard/widgets/dashboard_section_card.dart';
import '../../dashboard/widgets/dashboard_sidebar.dart';
import '../controllers/course_registration_controller.dart';
import '../models/course_model.dart';

class CourseRegistrationScreen extends StatefulWidget {
  const CourseRegistrationScreen({super.key});

  @override
  State<CourseRegistrationScreen> createState() =>
      _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState extends State<CourseRegistrationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseRegistrationController>().loadForCurrentStudent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          const ApplicantSidebar(currentRoute: AppRoutes.courseRegistration),
          Expanded(
            child: Consumer<CourseRegistrationController>(
              builder: (context, controller, child) {
                return Column(
                  children: [
                    const _StudentTopBar(title: 'Course Registration'),
                    if (controller.isLoading ||
                        controller.isRegistering ||
                        controller.isDropping)
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
                                const _PageHeader(),
                                SizedBox(height: 24.h),
                                _SummaryGrid(controller: controller),
                                SizedBox(height: 24.h),
                                if (!controller.isRegistrationOpen) ...[
                                  _MessageBanner(
                                    message:
                                        'Course registration is currently closed.',
                                    color: AppColors.warning,
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                                if (controller.errorMessage != null) ...[
                                  _MessageBanner(
                                    message: controller.errorMessage!,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                                if (controller.successMessage != null) ...[
                                  _MessageBanner(
                                    message: controller.successMessage!,
                                    color: AppColors.success,
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                                DashboardSectionCard(
                                  title: 'Available Courses',
                                  child: _AvailableCoursesTable(
                                    controller: controller,
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                DashboardSectionCard(
                                  title: 'Registered Courses',
                                  child: _RegisteredCoursesTable(
                                    controller: controller,
                                  ),
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

class _StudentTopBar extends StatelessWidget {
  const _StudentTopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final student = context.watch<CourseRegistrationController>().student;

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
            title,
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
                  Icons.school_outlined,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  student?.studentCode ?? 'Student Portal',
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

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Register Courses',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Choose from the courses assigned to you by the registration office.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.controller});

  final CourseRegistrationController controller;

  @override
  Widget build(BuildContext context) {
    final cards = [
      DashboardInfoCard(
        title: 'Registered Courses',
        value: controller.registeredCoursesCount.toString(),
        icon: Icons.library_books_outlined,
      ),
      DashboardInfoCard(
        title: 'Total Credit Hours',
        value: controller.totalRegisteredCredits.toString(),
        icon: Icons.timelapse_outlined,
      ),
      DashboardInfoCard(
        title: 'Maximum Allowed',
        value: controller.maxCreditHours.toString(),
        icon: Icons.rule_outlined,
      ),
      DashboardInfoCard(
        title: 'Remaining Credits',
        value: controller.remainingCreditHours.toString(),
        icon: Icons.add_task_outlined,
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

class _AvailableCoursesTable extends StatelessWidget {
  const _AvailableCoursesTable({required this.controller});

  final CourseRegistrationController controller;

  @override
  Widget build(BuildContext context) {
    final courses = controller.availableCourses;

    if (controller.isLoading) {
      return Padding(
        padding: EdgeInsets.all(32.w),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (courses.isEmpty) {
      return _EmptyState(
        title: 'No available courses',
        message: 'The registration office has not enabled courses for you yet.',
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 980.w,
        child: DataTable(
          columnSpacing: 22.w,
          headingRowColor: WidgetStatePropertyAll(AppColors.surfaceMuted),
          border: TableBorder(
            horizontalInside: BorderSide(color: AppColors.borderLight),
            bottom: BorderSide(color: AppColors.borderLight),
          ),
          columns: [
            _column('Course Code'),
            _column('Course Name'),
            _column('Credit Hours'),
            _column('Prerequisites'),
            _column('Action'),
          ],
          rows: courses
              .map(
                (item) => DataRow(
                  cells: [
                    _textCell(item.course.code, isStrong: true),
                    _textCell(item.course.name),
                    _textCell(item.course.creditHours.toString()),
                    _textCell(controller.prerequisiteLabelFor(item.course.id)),
                    DataCell(_RegisterButton(item: item)),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  DataColumn _column(String label) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  DataCell _textCell(String value, {bool isStrong = false}) {
    return DataCell(
      Text(
        value,
        style: TextStyle(
          color: isStrong ? AppColors.textPrimary : AppColors.textSecondary,
          fontSize: 12.sp,
          fontWeight: isStrong ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton({required this.item});

  final AvailableRegistrationCourse item;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CourseRegistrationController>();
    final isRegistered = controller.isRegistered(item.course.id);

    return TextButton(
      onPressed:
          isRegistered || controller.isRegistering || !controller.isRegistrationOpen
          ? null
          : () => controller.registerCourse(item),
      child: Text(isRegistered ? 'Registered' : 'Register'),
    );
  }
}

class _RegisteredCoursesTable extends StatelessWidget {
  const _RegisteredCoursesTable({required this.controller});

  final CourseRegistrationController controller;

  @override
  Widget build(BuildContext context) {
    final records = controller.registeredCourses;

    if (records.isEmpty) {
      return _EmptyState(
        title: 'No registered courses',
        message: 'Registered courses will appear here after successful registration.',
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 760.w,
        child: DataTable(
          columnSpacing: 22.w,
          headingRowColor: WidgetStatePropertyAll(AppColors.surfaceMuted),
          border: TableBorder(
            horizontalInside: BorderSide(color: AppColors.borderLight),
            bottom: BorderSide(color: AppColors.borderLight),
          ),
          columns: [
            _column('Course Code'),
            _column('Course Name'),
            _column('Credit Hours'),
            _column('Action'),
          ],
          rows: records
              .map(
                (record) => DataRow(
                  cells: [
                    _textCell(record.course.code, isStrong: true),
                    _textCell(record.course.name),
                    _textCell(record.course.creditHours.toString()),
                    DataCell(
                      TextButton(
                        onPressed:
                            controller.isDropping || !controller.isRegistrationOpen
                            ? null
                            : () => controller.dropCourse(record),
                        child: const Text('Drop Course'),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  DataColumn _column(String label) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  DataCell _textCell(String value, {bool isStrong = false}) {
    return DataCell(
      Text(
        value,
        style: TextStyle(
          color: isStrong ? AppColors.textPrimary : AppColors.textSecondary,
          fontSize: 12.sp,
          fontWeight: isStrong ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 44.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
