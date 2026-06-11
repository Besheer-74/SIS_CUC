import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/forms/app_dropdown_form_field.dart';
import '../../../../shared/widgets/forms/app_form_validators.dart';
import '../../../../shared/widgets/forms/app_text_form_field.dart';
import '../../controllers/application_controller.dart';
import '../../models/admission_lookup_option.dart';
import 'lookup_status_message.dart';

class StepSchoolInformation extends StatefulWidget {
  const StepSchoolInformation({super.key});

  @override
  State<StepSchoolInformation> createState() => StepSchoolInformationState();
}

class StepSchoolInformationState extends State<StepSchoolInformation> {
  final _formKey = GlobalKey<FormState>();
  final _schoolNameController = TextEditingController();
  final _highSchoolGradeController = TextEditingController();

  int? _certificateTypeId;
  int? _certificateSpecializationId;

  @override
  void initState() {
    super.initState();
    final application = context.read<ApplicationController>().application;
    _schoolNameController.text = application.schoolName;
    _highSchoolGradeController.text =
        application.highSchoolGrade?.toString() ?? '';
    _certificateTypeId = application.certificateTypeId;
    _certificateSpecializationId = application.certificateSpecializationId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ApplicationController>();
      controller.loadCertificateTypes();

      if (_certificateTypeId != null) {
        controller.loadCertificateSpecializations(_certificateTypeId!);
      }

      if (_certificateSpecializationId != null) {
        controller.loadAllowedFaculties(_certificateSpecializationId!);
      }
    });
  }

  bool submitStep() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return false;
    }

    context.read<ApplicationController>().updateStep4(
      schoolName: _schoolNameController.text,
      highSchoolGrade: double.tryParse(_highSchoolGradeController.text.trim()),
      certificateTypeId: _certificateTypeId!,
      certificateSpecializationId: _certificateSpecializationId!,
    );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationController>(
      builder: (context, controller, child) {
        final certificateTypeValue = _safeValue(
          _certificateTypeId,
          controller.certificateTypes,
        );
        final specializationValue = _safeValue(
          _certificateSpecializationId,
          controller.certificateSpecializations,
        );

        return Form(
          key: _formKey,
          child: Column(
            children: [
              if (controller.lookupErrorMessage != null) ...[
                LookupStatusMessage(message: controller.lookupErrorMessage!),
                SizedBox(height: 16.h),
              ],
              AppTextFormField(
                label: 'School Name',
                isRequired: true,
                icon: Icons.school_outlined,
                controller: _schoolNameController,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    AppFormValidators.required(value, fieldName: 'School name'),
              ),
              SizedBox(height: 16.h),
              AppDropdownFormField<int>(
                label: 'Certificate Type',
                isRequired: true,
                icon: Icons.workspace_premium_outlined,
                value: certificateTypeValue,
                onChanged: controller.isLoadingCertificateTypes
                    ? null
                    : (value) => _handleCertificateTypeChanged(value),
                validator: (value) =>
                    value == null ? 'Certificate type is required.' : null,
                items: controller.certificateTypes
                    .map(
                      (type) => DropdownMenuItem<int>(
                        value: type.id,
                        child: Text(type.name),
                      ),
                    )
                    .toList(),
              ),
              if (controller.isLoadingCertificateTypes) ...[
                SizedBox(height: 10.h),
                const LookupStatusMessage(
                  message: 'Loading certificate types...',
                  isLoading: true,
                ),
              ],
              SizedBox(height: 16.h),
              AppDropdownFormField<int>(
                label: 'Certificate Specialization',
                isRequired: true,
                icon: Icons.category_outlined,
                value: specializationValue,
                onChanged:
                    _certificateTypeId == null ||
                        controller.isLoadingCertificateSpecializations
                    ? null
                    : (value) => _handleSpecializationChanged(value),
                validator: (value) => value == null
                    ? 'Certificate specialization is required.'
                    : null,
                items: controller.certificateSpecializations
                    .map(
                      (specialization) => DropdownMenuItem<int>(
                        value: specialization.id,
                        child: Text(specialization.name),
                      ),
                    )
                    .toList(),
              ),
              if (_certificateTypeId == null) ...[
                SizedBox(height: 10.h),
                const LookupStatusMessage(
                  message:
                      'Select a certificate type to load available specializations.',
                ),
              ] else if (controller.isLoadingCertificateSpecializations) ...[
                SizedBox(height: 10.h),
                const LookupStatusMessage(
                  message: 'Loading certificate specializations...',
                  isLoading: true,
                ),
              ],
              SizedBox(height: 16.h),
              AppTextFormField(
                label: 'High School Grade',
                isRequired: true,
                icon: Icons.percent_rounded,
                controller: _highSchoolGradeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                validator: _validateGrade,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleCertificateTypeChanged(int? value) async {
    if (value == null) {
      return;
    }

    setState(() {
      _certificateTypeId = value;
      _certificateSpecializationId = null;
    });

    await context.read<ApplicationController>().loadCertificateSpecializations(
      value,
    );
  }

  Future<void> _handleSpecializationChanged(int? value) async {
    if (value == null) {
      return;
    }

    setState(() => _certificateSpecializationId = value);
    await context.read<ApplicationController>().loadAllowedFaculties(value);
  }

  int? _safeValue(int? value, List<AdmissionLookupOption> options) {
    if (value == null) {
      return null;
    }

    return options.any((option) => option.id == value) ? value : null;
  }

  String? _validateGrade(String? value) {
    final requiredResult = AppFormValidators.required(
      value,
      fieldName: 'High school grade',
    );
    if (requiredResult != null) {
      return requiredResult;
    }

    final grade = double.tryParse(value!.trim());
    if (grade == null || grade < 0 || grade > 100) {
      return 'Enter a valid grade from 0 to 100.';
    }

    return null;
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _highSchoolGradeController.dispose();
    super.dispose();
  }
}
