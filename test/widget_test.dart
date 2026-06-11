import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sis_cuc/core/theme/app_theme.dart';
import 'package:sis_cuc/features/admissions/controllers/application_controller.dart';
import 'package:sis_cuc/features/admissions/views/widgets/step_account_setup.dart';
import 'package:sis_cuc/shared/widgets/forms/app_text_form_field.dart';

void main() {
  testWidgets('Admission portal renders account setup step', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(1440, 900),
        builder: (context, child) {
          return ChangeNotifierProvider(
            create: (_) => ApplicationController(),
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: const SingleChildScrollView(
                      child: StepAccountSetup(),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.pump();

    expect(find.text('Egypt'), findsOneWidget);
    expect(find.byType(AppTextFormField), findsNWidgets(4));
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
  });
}
