import 'package:dino_merlin/Pages/Auth/Widgets/email_textfield.dart';
import 'package:dino_merlin/Pages/Auth/Widgets/entry_button.dart';
import 'package:dino_merlin/Pages/Auth/Widgets/password_textfield.dart';
import 'package:dino_merlin/Pages/Auth/Widgets/username_textfield.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  String username = "";
  String emailError = '';
  String usernameError = "";
  String passwordError = '';

  void register() async {
    setState(() {
      emailError = email.isEmpty ? 'Email is required' : '';
      passwordError = password.isEmpty ? 'Password is required' : '';
      usernameError = username.isEmpty ? "Username is required" : "";
    });

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      return;
    }

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      var uuid = const Uuid();
      String randomId = uuid.v4();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Succesfully Registered!"),
        duration: Duration(milliseconds: 500),
      ));
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'randomId': randomId,
        "username": username,
        "password": password,
      }).then((_) {
        print('User data added to Firestore');
      }).catchError((error) {
        print('Error adding user data: $error');
      });
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        //TODO: error codes
        switch (e.code) {
          case "invalid-email":
            emailError = "Invalid email";
            break;
          case "email-already-in-use":
            emailError = "Email already in use";
            break;
          case "weak-password":
            passwordError = "Weak password";
            break;
        }
      });
      print(e.message);
      print(e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              UsernameTextField(
                username: username,
                errorText: usernameError,
                onChanged: (value) {
                  setState(() {
                    username = value;
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
              EntryButton(onPressed: register, buttonText: "Register"),
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
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Already have an account?',
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

class BottomTextStyle {
  TextStyle bottomTextStyle = const TextStyle(
      color: Colors.deepPurple, fontSize: 15, fontWeight: FontWeight.w500);
}