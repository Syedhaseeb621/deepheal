import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const AppTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.isPassword = false,
    this.prefixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.textDisabled.withOpacity(0.8)),
            prefixIcon: prefixIcon != null 
              ? Icon(prefixIcon, color: AppColors.primary.withOpacity(0.8), size: 22)
              : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            filled: true,
            fillColor: AppColors.background.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
