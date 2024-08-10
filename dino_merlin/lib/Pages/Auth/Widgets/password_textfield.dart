import 'package:flutter/material.dart';

class PasswordTextField extends StatelessWidget {
  final String password;
  final String errorText;
  final Function(String) onChanged;

  const PasswordTextField({
    Key? key,
    required this.password,
    required this.errorText,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
          labelText: 'Password',
          errorText: errorText.isNotEmpty ? errorText : null,
          errorStyle: ErrorTextStyle().errorTextStyle,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
      obscureText: true,
    );
  }
}

class ErrorTextStyle {
  TextStyle errorTextStyle = const TextStyle(fontSize: 15);
}
