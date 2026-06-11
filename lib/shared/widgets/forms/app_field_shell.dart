import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

class AppFieldShell extends StatelessWidget {
  const AppFieldShell({
    super.key,
    required this.label,
    required this.child,
    this.icon,
    this.isRequired = false,
    this.isFocused = false,
    this.isFloating = false,
  });

  final String label;
  final Widget child;
  final IconData? icon;
  final bool isRequired;
  final bool isFocused;
  final bool isFloating;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      constraints: BoxConstraints(minHeight: 70.h),
      decoration: BoxDecoration(
        color: isFocused
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isFocused ? AppColors.primary : AppColors.borderLight,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 34.h, bottom: 12.h),
            child: child,
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            top: isFloating ? 10.h : 22.h,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16.sp, color: AppColors.primary),
                    SizedBox(width: 6.w),
                  ],
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.78),
                          fontSize: (isFloating ? 14 : 16).sp,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                        children: [
                          TextSpan(text: label),
                          if (isRequired)
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: AppColors.danger,
                                fontSize: (isFloating ? 14 : 16).sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
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
