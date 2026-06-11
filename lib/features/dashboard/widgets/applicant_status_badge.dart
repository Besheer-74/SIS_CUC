import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/application_model.dart';

class ApplicantStatusBadge extends StatelessWidget {
  const ApplicantStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final ApplicationStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9.w : 12.w,
        vertical: compact ? 5.h : 7.h,
      ),
      decoration: BoxDecoration(
        color: ApplicationStatusColor(status).color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: ApplicationStatusColor(status).color.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: ApplicationStatusColor(status).color,
          fontSize: compact ? 11.sp : 12.sp,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}
