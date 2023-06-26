import 'package:flutter/material.dart';

class InfoField extends StatelessWidget {
  const InfoField({
    super.key,
    required this.onChanged,
    this.obscureText = false,
    this.keyboard = TextInputType.text,
    required this.decoration,
  });

  final Function(String)? onChanged;
  final bool obscureText;
  final TextInputType keyboard;
  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: TextAlign.center,
      onChanged: onChanged,
      decoration: decoration,
      obscureText: obscureText,
      keyboardType: keyboard,
    );
  }
}
