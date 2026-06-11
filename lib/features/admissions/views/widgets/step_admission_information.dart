import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/forms/app_dropdown_form_field.dart';
import '../../controllers/application_controller.dart';
import '../../models/admission_lookup_option.dart';
import 'lookup_status_message.dart';

class StepAdmissionInformation extends StatefulWidget {
  const StepAdmissionInformation({super.key});

  @override
  State<StepAdmissionInformation> createState() =>
      StepAdmissionInformationState();
}

class StepAdmissionInformationState extends State<StepAdmissionInformation> {
  final _formKey = GlobalKey<FormState>();

  int? _facultyId;
  int? _majorId;

  @override
  void initState() {
    super.initState();
    final application = context.read<ApplicationController>().application;
    _facultyId = application.facultyId;
    _majorId = application.majorId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ApplicationController>();
      final specializationId =
          controller.application.certificateSpecializationId;

      if (specializationId != null && controller.allowedFaculties.isEmpty) {
        controller.loadAllowedFaculties(specializationId);
      }

      if (_facultyId != null) {
        controller.loadMajors(_facultyId!);
      }
    });
  }

  bool submitStep() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return false;
    }

    context.read<ApplicationController>().updateStep5(
      facultyId: _facultyId!,
      majorId: _majorId!,
    );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationController>(
      builder: (context, controller, child) {
        final facultyValue = _safeValue(
          _facultyId,
          controller.allowedFaculties,
        );
        final majorValue = _safeValue(_majorId, controller.majors);
        final canChooseFaculty =
            controller.application.certificateSpecializationId != null &&
            !controller.isLoadingAllowedFaculties;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              if (controller.lookupErrorMessage != null) ...[
                LookupStatusMessage(message: controller.lookupErrorMessage!),
                SizedBox(height: 16.h),
              ],
              AppDropdownFormField<int>(
                label: 'Faculty',
                isRequired: true,
                icon: Icons.account_balance_outlined,
                value: facultyValue,
                onChanged: canChooseFaculty
                    ? (value) => _handleFacultyChanged(value)
                    : null,
                validator: (value) =>
                    value == null ? 'Faculty is required.' : null,
                items: controller.allowedFaculties
                    .map(
                      (faculty) => DropdownMenuItem<int>(
                        value: faculty.id,
                        child: Text(faculty.name),
                      ),
                    )
                    .toList(),
              ),
              if (controller.application.certificateSpecializationId ==
                  null) ...[
                SizedBox(height: 10.h),
                const LookupStatusMessage(
                  message:
                      'Complete certificate specialization in School Information first.',
                ),
              ] else if (controller.isLoadingAllowedFaculties) ...[
                SizedBox(height: 10.h),
                const LookupStatusMessage(
                  message: 'Loading eligible faculties...',
                  isLoading: true,
                ),
              ] else if (controller.allowedFaculties.isEmpty) ...[
                SizedBox(height: 10.h),
                const LookupStatusMessage(
                  message:
                      'No eligible faculties were found for the selected specialization.',
                ),
              ],
              SizedBox(height: 16.h),
              AppDropdownFormField<int>(
                label: 'Major',
                isRequired: true,
                icon: Icons.menu_book_outlined,
                value: majorValue,
                onChanged: _facultyId == null || controller.isLoadingMajors
                    ? null
                    : (value) => setState(() => _majorId = value),
                validator: (value) =>
                    value == null ? 'Major is required.' : null,
                items: controller.majors
                    .map(
                      (major) => DropdownMenuItem<int>(
                        value: major.id,
                        child: Text(major.name),
                      ),
                    )
                    .toList(),
              ),
              if (_facultyId == null) ...[
                SizedBox(height: 10.h),
                const LookupStatusMessage(
                  message: 'Select a faculty to load available majors.',
                ),
              ] else if (controller.isLoadingMajors) ...[
                SizedBox(height: 10.h),
                const LookupStatusMessage(
                  message: 'Loading majors...',
                  isLoading: true,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleFacultyChanged(int? value) async {
    if (value == null) {
      return;
    }

    setState(() {
      _facultyId = value;
      _majorId = null;
    });

    await context.read<ApplicationController>().loadMajors(value);
  }

  int? _safeValue(int? value, List<AdmissionLookupOption> options) {
    if (value == null) {
      return null;
    }

    return options.any((option) => option.id == value) ? value : null;
  }
}
