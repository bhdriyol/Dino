import 'package:flutter/material.dart';

class UsernameTextField extends StatelessWidget {
  final String username;
  final String errorText;
  final Function(String) onChanged;

  const UsernameTextField({
    Key? key,
    required this.username,
    required this.errorText,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
          labelText: 'Username',
          errorText: errorText.isNotEmpty ? errorText : null,
          errorStyle: ErrorTextStyle().errorTextStyle,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
    );
  }
}

class ErrorTextStyle {
  TextStyle errorTextStyle = const TextStyle(fontSize: 15);
}
