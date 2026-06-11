import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import 'app_field_shell.dart';

class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.isRequired = false,
    this.obscureText = false,
    this.autofillHints,
    this.maxLines = 1,
    this.icon,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final bool isRequired;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final IconData? icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late final FocusNode _focusNode;

  bool get _hasValue => (widget.controller?.text.trim().isNotEmpty ?? false);

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
      isFloating: _focusNode.hasFocus || _hasValue,
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onChanged: (value) {
          setState(() {});
          widget.onChanged?.call(value);
        },
        obscureText: widget.obscureText,
        autofillHints: widget.autofillHints,
        maxLines: widget.maxLines,
        focusNode: _focusNode,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          height: 1.35,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hintText,
          suffixIcon: widget.suffixIcon,
          suffixIconConstraints: BoxConstraints(
            minWidth: 24.w,
            minHeight: 24.h,
          ),
          hintStyle: TextStyle(
            color: AppColors.mutedText,
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
          filled: false,
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
