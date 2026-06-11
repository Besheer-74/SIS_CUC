import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 45, child: _brandSection()),
          Expanded(flex: 55, child: _loginSection(context, authController)),
        ],
      ),
    );
  }

  Widget _brandSection() {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 48.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 48.r,
                backgroundColor: Colors.white,
                child: Image.asset(
                  'assets/images/cuc_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 16.w),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CUC Cairo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    'Student Information System',
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          Text(
            'Welcome Back',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            'Access your admission application, academic information and university services from one place.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16.sp,
              height: 1.6,
            ),
          ),

          SizedBox(height: 48.h),

          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withValues(alpha: .1)),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_user, color: AppColors.accent, size: 30.sp),

                SizedBox(width: 16.w),

                Expanded(
                  child: Text(
                    'Secure admission portal powered by City University Cairo.',
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _loginSection(BuildContext context, AuthController authController) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    return Center(
      child: Container(
        width: 420.w,
        padding: EdgeInsets.all(40.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign In',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 32.h),

            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),

            SizedBox(height: 20.h),

            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),

            SizedBox(height: 28.h),

            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await authController.login(
                    email: emailController.text.trim(),
                    password: passwordController.text,
                  );

                  if (!context.mounted) return;

                  if (success) {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.applicantDashboard,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Email or password is incorrect. Please try again.',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.newApplication,
                  );
                },
                child: Text(
                  'Start New Application',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
