import 'package:dino_merlin/Pages/Auth/Widgets/email_textfield.dart';
import 'package:dino_merlin/Pages/Auth/Widgets/entry_button.dart';
import 'package:dino_merlin/Pages/Auth/Widgets/password_textfield.dart';
import 'package:dino_merlin/Pages/BottomBar/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  String emailError = '';
  String passwordError = '';

  void login() async {
    setState(() {
      emailError = email.isEmpty ? 'Email is required' : '';
      passwordError = password.isEmpty ? 'Password is required' : '';
    });

    if (email.isEmpty || password.isEmpty) {
      return;
    }

    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomNavBar()));
    } catch (e) {
      setState(() {
        emailError = 'Login failed. Please check your credentials.';
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MainText().mainText,
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 80),
                child: Divider(
                  thickness: 4,
                ),
              ),
              const SizedBox(height: 30),
              EmailTextField(
                email: email,
                errorText: emailError,
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              PasswordTextField(
                password: password,
                errorText: passwordError,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              EntryButton(onPressed: login, buttonText: "Log in"),
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 80),
                child: Divider(
                  height: 20,
                  thickness: 4,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const RegisterPage()));
                },
                child: Text(
                  'Create an account',
                  style: BottomTextStyle().bottomTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainText {
  Text mainText = const Text(
    "DİNO",
    style:
        TextStyle(fontSize: 60, fontWeight: FontWeight.w800, letterSpacing: 20),
  );
}

class BottomTextStyle {
  TextStyle bottomTextStyle = const TextStyle(
      color: Colors.deepPurple, fontSize: 15, fontWeight: FontWeight.w500);
}
