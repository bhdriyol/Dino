import 'package:flutter/material.dart';

class EmailTextField extends StatelessWidget {
  final String email;
  final String errorText;
  final Function(String) onChanged;

  const EmailTextField({
    Key? key,
    required this.email,
    required this.errorText,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      decoration: InputDecoration(
          labelText: 'Email',
          errorText: errorText.isNotEmpty ? errorText : null,
          errorStyle: ErrorTextStyle().errorTextStyle,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
    );
  }
}

class ErrorTextStyle {
  TextStyle errorTextStyle = const TextStyle(fontSize: 15);
}
