import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/forms/app_dropdown_form_field.dart';
import '../../../../shared/widgets/forms/app_form_validators.dart';
import '../../../../shared/widgets/forms/app_text_form_field.dart';
import '../../controllers/application_controller.dart';

class StepPersonalInformation extends StatefulWidget {
  const StepPersonalInformation({super.key});

  @override
  State<StepPersonalInformation> createState() =>
      StepPersonalInformationState();
}

class StepPersonalInformationState extends State<StepPersonalInformation> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameEnController = TextEditingController();
  final _middleNameEnController = TextEditingController();
  final _familyNameEnController = TextEditingController();
  final _firstNameArController = TextEditingController();
  final _middleNameArController = TextEditingController();
  final _familyNameArController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender;

  static const List<String> _genders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    final application = context.read<ApplicationController>().application;
    _dateOfBirth = application.dateOfBirth;
    _gender = application.gender;

    if (_dateOfBirth != null) {
      _dateOfBirthController.text = _formatDate(_dateOfBirth!);
    }
  }

  bool submitStep() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return false;
    }

    context.read<ApplicationController>().updateStep2(
      firstNameEn: _firstNameEnController.text,
      middleNameEn: _middleNameEnController.text,
      familyNameEn: _familyNameEnController.text,
      firstNameAr: _firstNameArController.text,
      middleNameAr: _middleNameArController.text,
      familyNameAr: _familyNameArController.text,
      dateOfBirth: _dateOfBirth,
      gender: _gender,
    );

    return true;
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Select Date of Birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              secondary: AppColors.accent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _dateOfBirth = pickedDate;
      _dateOfBirthController.text = _formatDate(pickedDate);
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextFormField(
            label: 'First Name English',
            isRequired: true,
            icon: Icons.badge_outlined,
            controller: _firstNameEnController,
            textInputAction: TextInputAction.next,
            validator: (value) => AppFormValidators.required(
              value,
              fieldName: 'First name English',
            ),
          ),
          SizedBox(height: 16.h),
          AppTextFormField(
            label: 'Middle Name English',
            isRequired: true,
            icon: Icons.badge_outlined,
            controller: _middleNameEnController,
            textInputAction: TextInputAction.next,
            validator: (value) => AppFormValidators.required(
              value,
              fieldName: 'Middle name English',
            ),
          ),
          SizedBox(height: 16.h),
          AppTextFormField(
            label: 'Family Name English',
            isRequired: true,
            icon: Icons.badge_outlined,
            controller: _familyNameEnController,
            textInputAction: TextInputAction.next,
            validator: (value) => AppFormValidators.required(
              value,
              fieldName: 'Family name English',
            ),
          ),
          SizedBox(height: 16.h),
          AppTextFormField(
            label: 'First Name Arabic',
            icon: Icons.translate_rounded,
            controller: _firstNameArController,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 16.h),
          AppTextFormField(
            label: 'Middle Name Arabic',
            icon: Icons.translate_rounded,
            controller: _middleNameArController,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 16.h),
          AppTextFormField(
            label: 'Family Name Arabic',
            icon: Icons.translate_rounded,
            controller: _familyNameArController,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 16.h),
          AppTextFormField(
            label: 'Date of Birth',
            isRequired: true,
            icon: Icons.calendar_month_outlined,
            controller: _dateOfBirthController,
            readOnly: true,
            onTap: _pickDateOfBirth,
            suffixIcon: Icon(
              Icons.expand_more_rounded,
              size: 22.sp,
              color: AppColors.textPrimary,
            ),
            validator: (value) =>
                AppFormValidators.required(value, fieldName: 'Date of birth'),
          ),
          SizedBox(height: 16.h),
          AppDropdownFormField<String>(
            label: 'Gender',
            isRequired: true,
            icon: Icons.wc_rounded,
            value: _gender,
            onChanged: (value) => setState(() => _gender = value),
            validator: (value) => value == null ? 'Gender is required.' : null,
            items: _genders
                .map(
                  (gender) => DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameEnController.dispose();
    _middleNameEnController.dispose();
    _familyNameEnController.dispose();
    _firstNameArController.dispose();
    _middleNameArController.dispose();
    _familyNameArController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }
}
