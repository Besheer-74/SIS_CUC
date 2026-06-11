import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../controllers/application_controller.dart';
import '../controllers/document_controller.dart';
import 'widgets/admission_portal_shell.dart';
import 'widgets/admission_stepper.dart';
import 'widgets/step_admission_information.dart';
import 'widgets/step_account_setup.dart';
import 'widgets/step_confirm_application.dart';
import 'widgets/step_contact_information.dart';
import 'widgets/step_personal_information.dart';
import 'widgets/step_school_information.dart';
import 'widgets/step_upload_documents.dart';

class NewApplicationScreen extends StatefulWidget {
  const NewApplicationScreen({super.key});

  @override
  State<NewApplicationScreen> createState() => _NewApplicationScreenState();
}

class _NewApplicationScreenState extends State<NewApplicationScreen> {
  final GlobalKey<StepAccountSetupState> _accountSetupKey =
      GlobalKey<StepAccountSetupState>();
  final GlobalKey<StepPersonalInformationState> _personalInformationKey =
      GlobalKey<StepPersonalInformationState>();
  final GlobalKey<StepContactInformationState> _contactInformationKey =
      GlobalKey<StepContactInformationState>();
  final GlobalKey<StepSchoolInformationState> _schoolInformationKey =
      GlobalKey<StepSchoolInformationState>();
  final GlobalKey<StepAdmissionInformationState> _admissionInformationKey =
      GlobalKey<StepAdmissionInformationState>();

  static const List<AdmissionStepDefinition> _stepDefinitions = [
    AdmissionStepDefinition(['Account', 'Setup']),
    AdmissionStepDefinition(['Personal', 'Information']),
    AdmissionStepDefinition(['Contact', 'Information']),
    AdmissionStepDefinition(['School', 'Information']),
    AdmissionStepDefinition(['Admission', 'Information']),
    AdmissionStepDefinition(['Upload', 'Documents']),
    AdmissionStepDefinition(['Confirm', 'Application']),
  ];

  static const List<String> _stepTitles = [
    'Account Setup',
    'Personal Information',
    'Contact Information',
    'School Information',
    'Admission Information',
    'Upload Documents',
    'Confirm Application',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<ApplicationController, DocumentController>(
      builder: (context, controller, documentController, child) {
        return AdmissionPortalShell(
          currentStep: controller.currentStep,
          title: _stepTitles[controller.currentStep - 1],
          stepDefinitions: _stepDefinitions,
          onBackPressed: controller.currentStep > 1
              ? controller.previousStep
              : null,
          onPrimaryPressed: () => _handlePrimaryAction(controller),
          primaryLabel:
              controller.currentStep == ApplicationController.totalSteps
              ? 'Submit'
              : 'Next',
          isPrimaryEnabled:
              !controller.isLoading && !documentController.isLoading,
          child: _buildStepContent(controller.currentStep),
        );
      },
    );
  }

  Future<void> _handlePrimaryAction(ApplicationController controller) async {
    if (controller.currentStep == 1) {
      final isValid = _accountSetupKey.currentState?.submitStep() ?? false;
      if (isValid) {
        controller.nextStep();
      }

      return;
    }

    if (controller.currentStep == 2) {
      final isValid =
          _personalInformationKey.currentState?.submitStep() ?? false;
      if (isValid) {
        controller.nextStep();
      }

      return;
    }

    if (controller.currentStep == 3) {
      final isValid =
          _contactInformationKey.currentState?.submitStep() ?? false;
      if (isValid) {
        controller.nextStep();
      }

      return;
    }

    if (controller.currentStep == 4) {
      final isValid = _schoolInformationKey.currentState?.submitStep() ?? false;
      if (isValid) {
        controller.nextStep();
      }

      return;
    }

    if (controller.currentStep == 5) {
      final isValid =
          _admissionInformationKey.currentState?.submitStep() ?? false;
      if (isValid) {
        controller.nextStep();
      }

      return;
    }

    if (controller.currentStep == 6) {
      final isValid = StepUploadDocuments.validateRequiredDocuments(context);
      if (isValid) {
        controller.nextStep();
      }

      return;
    }

    if (controller.currentStep == 7) {
      await _submitFinalApplication(controller);
      return;
    }

    if (controller.currentStep < ApplicationController.totalSteps) {
      controller.nextStep();
    }
  }

  Future<void> _submitFinalApplication(ApplicationController controller) async {
    final documentController = context.read<DocumentController>();
    final messenger = ScaffoldMessenger.of(context);

    final applicationCreated = await controller.submitApplication();
    if (!applicationCreated || controller.application.id == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ?? 'Unable to submit application.',
          ),
        ),
      );
      return;
    }

    final documentsUploaded = await documentController.uploadPendingDocuments(
      applicationId: controller.application.id!,
    );

    if (!documentsUploaded) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            documentController.errorMessage ??
                'Application was created, but document upload failed.',
          ),
        ),
      );
      return;
    }

    messenger.showSnackBar(
      const SnackBar(content: Text('Application submitted successfully.')),
    );
    if (!mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 1:
        return StepAccountSetup(key: _accountSetupKey);
      case 2:
        return StepPersonalInformation(key: _personalInformationKey);
      case 3:
        return StepContactInformation(key: _contactInformationKey);
      case 4:
        return StepSchoolInformation(key: _schoolInformationKey);
      case 5:
        return StepAdmissionInformation(key: _admissionInformationKey);
      case 6:
        return const StepUploadDocuments();
      case 7:
        return const StepConfirmApplication();
      default:
        return const SizedBox.shrink();
    }
  }
}
