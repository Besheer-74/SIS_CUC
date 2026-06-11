import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/forms/app_form_validators.dart';
import '../../../../shared/widgets/forms/app_text_form_field.dart';
import '../../controllers/application_controller.dart';

class StepContactInformation extends StatefulWidget {
  const StepContactInformation({super.key});

  @override
  State<StepContactInformation> createState() => StepContactInformationState();
}

class StepContactInformationState extends State<StepContactInformation> {
  final _formKey = GlobalKey<FormState>();
  final _personalEmailController = TextEditingController();
  final _guardianEmailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _alternatePhoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final application = context.read<ApplicationController>().application;
    _personalEmailController.text = application.email;
    _guardianEmailController.text = application.guardianEmail ?? '';
    _phoneNumberController.text = application.mobile;
    _alternatePhoneNumberController.text = application.alternateMobile ?? '';
  }

  bool submitStep() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return false;
    }

    context.read<ApplicationController>().updateStep3(
      email: _personalEmailController.text,
      mobile: _phoneNumberController.text,
      guardianEmail: _guardianEmailController.text,
      alternateMobile: _alternatePhoneNumberController.text,
    );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextFormField(
            label: 'Personal Email',
            isRequired: true,
            icon: Icons.alternate_email_rounded,
            controller: _personalEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: AppFormValidators.email,
          ),
          SizedBox(height: 16.h),
          AppTextFormField(
            label: 'Guardian Email',
            icon: Icons.mark_email_read_outlined,
            controller: _guardianEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) => AppFormValidators.optionalEmail(
              value,
              fieldName: 'guardian email',
            ),
          ),
          SizedBox(height: 16.h),
          AppTextFormField(
            label: 'Phone Number',
            isRequired: true,
            icon: Icons.phone_iphone_rounded,
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            validator: (value) =>
                AppFormValidators.phone(value, fieldName: 'Phone number'),
          ),
          SizedBox(height: 16.h),
          AppTextFormField(
            label: 'Alternate Phone Number',
            icon: Icons.phone_outlined,
            controller: _alternatePhoneNumberController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _personalEmailController.dispose();
    _guardianEmailController.dispose();
    _phoneNumberController.dispose();
    _alternatePhoneNumberController.dispose();
    super.dispose();
  }
}
