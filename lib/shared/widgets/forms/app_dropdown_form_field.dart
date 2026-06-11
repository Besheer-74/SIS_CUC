import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import 'app_field_shell.dart';

class AppDropdownFormField<T> extends StatefulWidget {
  const AppDropdownFormField({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.hintText,
    this.isRequired = false,
    this.icon,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final String? hintText;
  final bool isRequired;
  final IconData? icon;

  @override
  State<AppDropdownFormField<T>> createState() =>
      _AppDropdownFormFieldState<T>();
}

class _AppDropdownFormFieldState<T> extends State<AppDropdownFormField<T>> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFieldShell(
      label: widget.label,
      isRequired: widget.isRequired,
      icon: widget.icon,
      isFocused: _focusNode.hasFocus,
      isFloating: _focusNode.hasFocus || widget.value != null,
      child: DropdownButtonFormField<T>(
        key: ValueKey<T?>(widget.value),
        focusNode: _focusNode,
        initialValue: widget.value,
        items: widget.items,
        onChanged: widget.onChanged,
        validator: widget.validator,
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textPrimary,
          size: 24.sp,
        ),
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          height: 1.35,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppColors.mutedText,
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          errorStyle: TextStyle(
            color: AppColors.error,
            fontSize: 12.sp,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }
}
