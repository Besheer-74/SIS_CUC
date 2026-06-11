import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/buttons/app_action_button.dart';
import 'admission_stepper.dart';

class AdmissionPortalShell extends StatelessWidget {
  const AdmissionPortalShell({
    super.key,
    required this.currentStep,
    required this.title,
    required this.child,
    required this.onPrimaryPressed,
    required this.stepDefinitions,
    this.onBackPressed,
    this.primaryLabel = 'Next',
    this.isPrimaryEnabled = true,
  });

  final int currentStep;
  final String title;
  final Widget child;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onBackPressed;
  final String primaryLabel;
  final bool isPrimaryEnabled;
  final List<AdmissionStepDefinition> stepDefinitions;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth >= 1440
        ? 72.w
        : screenWidth >= 1100
        ? 40.w
        : 20.w;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _AdmissionPortalHeader(screenWidth: screenWidth),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                28.h,
                horizontalPadding,
                32.h,
              ),
              child: Column(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 760.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 20.sp,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Fields marked * are required',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              Text(
                                'Step $currentStep out of ${stepDefinitions.length}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(
                              48.w,
                              40.h,
                              48.w,
                              24.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 32.r,
                                  spreadRadius: 4.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AdmissionStepper(
                                  currentStep: currentStep,
                                  steps: stepDefinitions,
                                ),
                                SizedBox(height: 64.h),
                                Text(
                                  title,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 1.25,
                                    letterSpacing: -0.32,
                                  ),
                                ),
                                SizedBox(height: 40.h),
                                child,
                                SizedBox(height: 32.h),
                                Wrap(
                                  spacing: 16.w,
                                  runSpacing: 12.h,
                                  children: [
                                    AppActionButton(
                                      label: 'Back',
                                      icon: Icons.chevron_left_rounded,
                                      variant: AppActionButtonVariant.secondary,
                                      onPressed: onBackPressed,
                                    ),
                                    AppActionButton(
                                      label: primaryLabel,
                                      icon: Icons.chevron_right_rounded,
                                      onPressed: isPrimaryEnabled
                                          ? onPrimaryPressed
                                          : null,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 64.h),
                                Center(
                                  child: Text.rich(
                                    TextSpan(
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                        height: 1.57,
                                        letterSpacing: -0.08,
                                      ),
                                      children: const [
                                        TextSpan(text: 'Need help? '),
                                        TextSpan(
                                          text: 'Contact Us!',
                                          style: TextStyle(
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: AppColors.accent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  const _AdmissionPortalFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdmissionPortalHeader extends StatelessWidget {
  const _AdmissionPortalHeader({required this.screenWidth});

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final isTablet = screenWidth < 1024;
    final logoSize = isTablet ? 56.w : 72.w;
    final leftTitleSize = isTablet ? 20.sp : 24.sp;
    final leftSubtitleSize = isTablet ? 16.sp : 18.sp;
    final rightTitleSize = isTablet ? 18.sp : 20.sp;
    final rightSubtitleSize = isTablet ? 15.sp : 16.sp;
    final horizontalPadding = screenWidth >= 1440
        ? 72.w
        : screenWidth >= 1100
        ? 40.w
        : 20.w;

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isTablet ? 18.h : 20.h,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1280.w),
          child: isTablet
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderIdentityBlock(
                      logoSize: logoSize,
                      leftTitleSize: leftTitleSize,
                      leftSubtitleSize: leftSubtitleSize,
                    ),
                    SizedBox(height: 16.h),
                    _HeaderApplicationBlock(
                      rightTitleSize: rightTitleSize,
                      rightSubtitleSize: rightSubtitleSize,
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _HeaderIdentityBlock(
                        logoSize: logoSize,
                        leftTitleSize: leftTitleSize,
                        leftSubtitleSize: leftSubtitleSize,
                      ),
                    ),
                    SizedBox(width: 40.w),
                    _HeaderApplicationBlock(
                      rightTitleSize: rightTitleSize,
                      rightSubtitleSize: rightSubtitleSize,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HeaderIdentityBlock extends StatelessWidget {
  const _HeaderIdentityBlock({
    required this.logoSize,
    required this.leftTitleSize,
    required this.leftSubtitleSize,
  });

  final double logoSize;
  final double leftTitleSize;
  final double leftSubtitleSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.asset(
            'assets/images/cuc_logo.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 16.w),
        Container(
          width: 1.w,
          height: logoSize,
          color: Colors.white.withValues(alpha: 0.3),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'City University of Cairo',
                style: TextStyle(
                  color: AppColors.headerText,
                  fontSize: leftTitleSize,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Applicant Portal',
                style: TextStyle(
                  color: AppColors.headerText.withValues(alpha: 0.9),
                  fontSize: leftSubtitleSize,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderApplicationBlock extends StatelessWidget {
  const _HeaderApplicationBlock({
    required this.rightTitleSize,
    required this.rightSubtitleSize,
  });

  final double rightTitleSize;
  final double rightSubtitleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Online Admission Application',
          style: TextStyle(
            color: AppColors.headerText,
            fontSize: rightTitleSize,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '2026/2027 - (Fall)',
          style: TextStyle(
            color: AppColors.headerText.withValues(alpha: 0.9),
            fontSize: rightSubtitleSize,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _AdmissionPortalFooter extends StatelessWidget {
  const _AdmissionPortalFooter();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 980.w),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12.h,
        spacing: 24.w,
        children: [
          Text(
            '© 2026 All Rights Reserved by CUC.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 1.57,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Powered by',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.57,
                ),
              ),
              SizedBox(width: 10.w),
              Image.asset(
                'assets/images/oro_logo.png',
                height: 18.h,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
