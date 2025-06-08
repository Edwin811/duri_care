import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.autovalidateMode,
    this.enabled,
    this.readOnly = false,
    this.style,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool? enabled;
  final bool readOnly;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = enabled == false;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      style:
          style ??
          TextStyle(
            color:
                isDisabled
                    ? Colors.grey.shade600
                    : Theme.of(context).textTheme.bodyLarge?.color,
          ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDisabled ? Colors.grey.shade500 : Colors.grey.shade600,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color:
              isDisabled
                  ? Colors.grey.shade500
                  : Theme.of(context).iconTheme.color,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDisabled ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDisabled ? Colors.grey.shade300 : Colors.grey.shade400,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      validator: validator,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
    );
  }
}
