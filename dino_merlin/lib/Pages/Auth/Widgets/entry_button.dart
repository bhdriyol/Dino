import 'package:flutter/material.dart';

class EntryButton extends StatelessWidget {
  EntryButton({super.key, required this.onPressed, required this.buttonText});
  final Function() onPressed;
  String buttonText = "";
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 370,
        height: 45,
        child: FilledButton(
            onPressed: onPressed,
            style: LoginButtonStyle().buttonStyle,
            child: Text(
              buttonText,
              style: LoginTextStyle().loginTextStyle,
            )));
  }
}

class LoginTextStyle {
  TextStyle loginTextStyle = const TextStyle(fontSize: 20);
}

class LoginButtonStyle {
  ButtonStyle buttonStyle = const ButtonStyle(
      backgroundColor: WidgetStatePropertyAll<Color>(Colors.white));
}
