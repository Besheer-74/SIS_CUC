import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

enum AppActionButtonVariant { primary, secondary }

class AppActionButton extends StatelessWidget {
  const AppActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppActionButtonVariant.primary,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppActionButtonVariant variant;
  final double? width;

  bool get _isPrimary => variant == AppActionButtonVariant.primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 124.w,
      height: 48.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return _isPrimary
                  ? AppColors.accent.withValues(alpha: 0.35)
                  : AppColors.disabledBackground;
            }

            if (states.contains(WidgetState.hovered)) {
              return _isPrimary
                  ? const Color(0xFFD2A845)
                  : const Color(0xFFEAEAEA);
            }

            return _isPrimary ? AppColors.accent : AppColors.disabledBackground;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (_isPrimary) {
              return AppColors.headerText;
            }

            if (states.contains(WidgetState.disabled)) {
              return AppColors.textPrimary.withValues(alpha: 0.35);
            }

            return AppColors.textPrimary;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withValues(alpha: 0.05);
            }

            return null;
          }),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20.sp),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                height: 1.5,
                letterSpacing: -0.18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
