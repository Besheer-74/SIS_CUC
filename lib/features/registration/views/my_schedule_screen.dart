import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../dashboard/widgets/dashboard_info_card.dart';
import '../../dashboard/widgets/dashboard_section_card.dart';
import '../../dashboard/widgets/dashboard_sidebar.dart';
import '../controllers/course_registration_controller.dart';

class MyScheduleScreen extends StatefulWidget {
  const MyScheduleScreen({super.key});

  @override
  State<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
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
          const ApplicantSidebar(currentRoute: AppRoutes.mySchedule),
          Expanded(
            child: Consumer<CourseRegistrationController>(
              builder: (context, controller, child) {
                return Column(
                  children: [
                    const _StudentTopBar(title: 'My Schedule'),
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
                                const _PageHeader(),
                                SizedBox(height: 24.h),
                                _SummaryGrid(controller: controller),
                                SizedBox(height: 24.h),
                                if (controller.errorMessage != null) ...[
                                  _MessageBanner(
                                    message: controller.errorMessage!,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                                DashboardSectionCard(
                                  title: 'Registered Courses',
                                  child: _ScheduleTable(controller: controller),
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
          'Registered Schedule',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'View your registered courses and timetable details.',
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
        title: 'Registered Courses Count',
        value: controller.registeredCoursesCount.toString(),
        icon: Icons.library_books_outlined,
      ),
      DashboardInfoCard(
        title: 'Total Credit Hours',
        value: controller.totalRegisteredCredits.toString(),
        icon: Icons.timelapse_outlined,
      ),
      DashboardInfoCard(
        title: 'Maximum Allowed Credit Hours',
        value: controller.maxCreditHours.toString(),
        icon: Icons.rule_outlined,
      ),
      DashboardInfoCard(
        title: 'Remaining Credit Hours',
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

class _ScheduleTable extends StatelessWidget {
  const _ScheduleTable({required this.controller});

  final CourseRegistrationController controller;

  @override
  Widget build(BuildContext context) {
    final records = controller.registeredCourses;

    if (controller.isLoading) {
      return Padding(
        padding: EdgeInsets.all(32.w),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (records.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(32.w),
        child: Center(
          child: Text(
            'No registered courses yet.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1120.w,
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
            _column('Semester'),
            _column('Section'),
            _column('Instructor'),
            _column('Day'),
            _column('Time'),
            _column('Room'),
          ],
          rows: records
              .map(
                (record) => DataRow(
                  cells: [
                    _textCell(record.course.code, isStrong: true),
                    _textCell(record.course.name),
                    _textCell(record.course.creditHours.toString()),
                    _textCell(record.semester),
                    _textCell(_placeholder(record.section)),
                    _textCell(_placeholder(record.instructor)),
                    _textCell(_placeholder(record.day)),
                    _textCell(_placeholder(record.time)),
                    _textCell(_placeholder(record.room)),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _placeholder(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? 'TBA' : text;
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
