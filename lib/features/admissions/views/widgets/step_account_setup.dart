import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/forms/app_dropdown_form_field.dart';
import '../../../../shared/widgets/forms/app_form_validators.dart';
import '../../../../shared/widgets/forms/app_text_form_field.dart';
import '../../controllers/application_controller.dart';

class StepAccountSetup extends StatefulWidget {
  const StepAccountSetup({super.key});

  @override
  State<StepAccountSetup> createState() => StepAccountSetupState();
}

class StepAccountSetupState extends State<StepAccountSetup> {
  final _formKey = GlobalKey<FormState>();
  final _identityNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _captchaController = TextEditingController();

  late String _selectedNationality;

  static const List<String> _nationalities = [
    'Egypt',
    'Saudi Arabia',
    'United Arab Emirates',
    'Kuwait',
    'Jordan',
    'Sudan',
    'Other',
  ];

  bool get _isEgyptian => _selectedNationality == 'Egypt';

  double get _passwordStrength {
    final password = _passwordController.text.trim();
    var score = 0.0;

    if (password.length >= 8) score += 0.35;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 0.25;

    return score.clamp(0, 1);
  }

  String get _passwordStrengthLabel {
    if (_passwordStrength >= 0.8) return 'Strong';
    if (_passwordStrength >= 0.45) return 'Good';
    if (_passwordStrength > 0) return 'Weak';
    return '';
  }

  Color get _passwordStrengthColor {
    if (_passwordStrength >= 0.8) return AppColors.success;
    if (_passwordStrength >= 0.45) return AppColors.accent;
    return AppColors.error;
  }

  @override
  void initState() {
    super.initState();
    final application = context.read<ApplicationController>().application;
    _selectedNationality = application.nationality;
    _identityNumberController.text = application.nationalId;
  }

  bool submitStep() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return false;
    }

    context.read<ApplicationController>().updateStep1(
      nationality: _selectedNationality,
      nationalId: _identityNumberController.text.trim(),
      password: _passwordController.text,
    );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppDropdownFormField<String>(
            label: 'Nationality',
            isRequired: true,
            icon: Icons.flag_rounded,
            value: _selectedNationality,
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() => _selectedNationality = value);
            },
            validator: (value) =>
                value == null ? 'Nationality is required.' : null,
            items: _nationalities
                .map(
                  (nationality) => DropdownMenuItem<String>(
                    value: nationality,
                    child: Text(nationality),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 16.h),
          AppTextFormField(
            label: _isEgyptian ? 'National ID' : 'Passport Number',
            isRequired: true,
            icon: _isEgyptian
                ? Icons.perm_identity_rounded
                : Icons.travel_explore_rounded,
            controller: _identityNumberController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final requiredResult = AppFormValidators.required(
                value,
                fieldName: _isEgyptian ? 'National ID' : 'Passport number',
              );
              if (requiredResult != null) {
                return requiredResult;
              }

              final trimmed = value!.trim();
              if (_isEgyptian && trimmed.length != 14) {
                return 'National ID must be 14 digits.';
              }

              if (!_isEgyptian && trimmed.length < 6) {
                return 'Passport number looks too short.';
              }

              return null;
            },
          ),
          SizedBox(height: 16.h),
          AppTextFormField(
            label: 'Password',
            isRequired: true,
            icon: Icons.lock_outline_rounded,
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            onChanged: (_) => setState(() {}),
            validator: AppFormValidators.password,
          ),
          if (_passwordController.text.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: LinearProgressIndicator(
                value: _passwordStrength,
                minHeight: 4.h,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _passwordStrengthColor,
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              _passwordStrengthLabel,
              style: TextStyle(
                color: _passwordStrengthColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          SizedBox(height: 16.h),
          AppTextFormField(
            label: 'Confirm Password',
            isRequired: true,
            icon: Icons.lock_rounded,
            controller: _confirmPasswordController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            validator: (value) => AppFormValidators.confirmPassword(
              value,
              _passwordController.text,
            ),
          ),
          SizedBox(height: 16.h),
          const _CaptchaPlaceholder(),
          SizedBox(height: 16.h),
          AppTextFormField(
            label: 'Captcha Numbers',
            isRequired: true,
            icon: Icons.visibility_outlined,
            controller: _captchaController,
            textInputAction: TextInputAction.done,
            validator: (value) =>
                AppFormValidators.required(value, fieldName: 'Captcha'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _identityNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }
}

class _CaptchaPlaceholder extends StatelessWidget {
  const _CaptchaPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5EF),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        '918 573',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}
