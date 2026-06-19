import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/controllers/auth_controller.dart';

class AdminSidebar extends StatefulWidget {
  final String currentRoute;

  const AdminSidebar({super.key, required this.currentRoute});

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  late String _activeRoute;

  @override
  void initState() {
    super.initState();
    _activeRoute = widget.currentRoute;
  }

  void _navigateTo(String routeName) {
    if (_activeRoute != routeName) {
      setState(() => _activeRoute = routeName);
      Navigator.pushReplacementNamed(context, routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 268.w,
      height: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.asset(
                  'assets/images/cuc_logo.png',
                  width: 52.w,
                  height: 52.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Portal',
                      style: TextStyle(
                        color: AppColors.headerText,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'City University of Cairo',
                      style: TextStyle(
                        color: AppColors.headerText.withValues(alpha: 0.72),
                        fontSize: 12.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 36.h),
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            isActive: _activeRoute == AppRoutes.adminDashboard,
            onTap: () => _navigateTo(AppRoutes.adminDashboard),
          ),
          _SidebarItem(
            icon: Icons.assignment_outlined,
            label: 'Applications',
            isActive: _activeRoute == AppRoutes.applications,
            onTap: () => _navigateTo(AppRoutes.applications),
          ),
          _SidebarItem(
            icon: Icons.people_outline_rounded,
            label: 'Students',
            isActive: _activeRoute == AppRoutes.students,
            onTap: () => _navigateTo(AppRoutes.students),
          ),
          _SidebarItem(
            icon: Icons.app_registration_rounded,
            label: 'Registration',
            isActive: _activeRoute == AppRoutes.registration,
            onTap: () => _navigateTo(AppRoutes.registration),
          ),
          const Spacer(),
          _SidebarItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            onTap: () async {
              await context.read<AuthController>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isActive
                  ? AppColors.accent.withValues(alpha: 0.55)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive
                    ? AppColors.accent
                    : AppColors.headerText.withValues(alpha: 0.75),
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.headerText.withValues(
                    alpha: isActive ? 1 : 0.78,
                  ),
                  fontSize: 14.sp,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
