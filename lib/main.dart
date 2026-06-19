import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/config/supabase_config.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_routes.dart';

import 'core/theme/app_theme.dart';

import 'features/admin/controllers/admin_controller.dart';
import 'features/admin/controllers/course_controller.dart';
import 'features/admissions/controllers/application_controller.dart';
import 'features/admissions/controllers/document_controller.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/dashboard/controllers/applicant_dashboard_controller.dart';
import 'features/registration/controllers/course_registration_controller.dart';

import 'features/auth/views/splash_screen.dart';
import 'features/auth/views/login_screen.dart';
import 'features/admissions/views/new_application_screen.dart';
import 'features/dashboard/views/applicant_dashboard_screen.dart';
import 'features/dashboard/views/my_application_screen.dart';
import 'features/admin/views/admin_dashboard_screen.dart';
import 'features/admin/views/applications_screen.dart';
import 'features/admin/views/application_review_screen.dart';
import 'features/admin/views/students_screen.dart';
import 'features/admin/views/registration_management_screen.dart';
import 'features/registration/views/course_registration_screen.dart';
import 'features/registration/views/my_schedule_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 900),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthController()),
            ChangeNotifierProvider(create: (_) => ApplicationController()),
            ChangeNotifierProvider(create: (_) => DocumentController()),
            ChangeNotifierProvider(
              create: (_) => ApplicantDashboardController(),
            ),
            ChangeNotifierProvider(create: (_) => AdminController()),
            ChangeNotifierProvider(create: (_) => CourseController()),
            ChangeNotifierProvider(
              create: (_) => CourseRegistrationController(),
            ),
          ],
          child: MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (_) => const SplashScreen(),
              AppRoutes.login: (_) => LoginScreen(),
              AppRoutes.newApplication: (_) => const NewApplicationScreen(),
              AppRoutes.applicantDashboard: (_) => const ApplicantDashboard(),
              AppRoutes.myApplication: (_) => const MyApplicationScreen(),
              AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(),
              AppRoutes.applications: (_) => const ApplicationsScreen(),
              AppRoutes.students: (_) => const StudentsScreen(),
              AppRoutes.registration: (_) =>
                  const RegistrationManagementScreen(),
              AppRoutes.courseRegistration: (_) =>
                  const CourseRegistrationScreen(),
              AppRoutes.mySchedule: (_) => const MyScheduleScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == AppRoutes.applicationReview) {
                final applicationId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (_) =>
                      ApplicationReviewScreen(applicationId: applicationId),
                );
              }
              return null;
            },
          ),
        );
      },
    );
  }
}
