import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/config/supabase_config.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_routes.dart';

import 'core/theme/app_theme.dart';

import 'features/admin/controllers/admin_controller.dart';
import 'features/admissions/controllers/application_controller.dart';
import 'features/admissions/controllers/document_controller.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/dashboard/controllers/applicant_dashboard_controller.dart';

import 'features/auth/views/splash_screen.dart';
import 'features/auth/views/login_screen.dart';
import 'features/admissions/views/new_application_screen.dart';
import 'features/dashboard/views/applicant_dashboard_screen.dart';
import 'features/admin/views/admin_dashboard_screen.dart';
import 'features/admin/views/applications_screen.dart';
import 'features/admin/views/application_review_screen.dart';
import 'features/admin/views/students_screen.dart';

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
      designSize: const Size(1440, 900), // Good for Web
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
          ],
          child: MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (_) => const SplashScreen(),
              AppRoutes.login: (_) => const LoginScreen(),
              AppRoutes.newApplication: (_) => const NewApplicationScreen(),
              AppRoutes.applicantDashboard: (_) => const ApplicantDashboard(),
              AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(),
              AppRoutes.applications: (_) => const ApplicationsScreen(),
              AppRoutes.students: (_) => const StudentsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == AppRoutes.applicationReview) {
                final applicationId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (_) => ApplicationReviewScreen(
                    applicationId: applicationId,
                  ),
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
