import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class AdmissionStepDefinition {
  const AdmissionStepDefinition(this.labelLines);

  final List<String> labelLines;
}

class AdmissionStepper extends StatelessWidget {
  const AdmissionStepper({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  final int currentStep;
  final List<AdmissionStepDefinition> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber == currentStep;
        final isCompleted = stepNumber < currentStep;
        final step = steps[index];

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == steps.length - 1 ? 0 : 6.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 42.h,
                  child: Text(
                    step.labelLines.join('\n'),
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(
                        alpha: isCompleted || isActive ? 1 : 0.8,
                      ),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.accent
                        : isCompleted
                        ? AppColors.primary
                        : AppColors.textPrimary.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(index == 0 ? 4.r : 0),
                      right: Radius.circular(
                        index == steps.length - 1 ? 4.r : 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
