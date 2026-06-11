import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

BoxDecoration dashboardCardDecoration() {
  return BoxDecoration(
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
  );
}
