import 'package:dino_merlin/Pages/Auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dino',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        splashFactory: NoSplash.splashFactory,
      ),
      home: const LoginPage(),
    );
  }
}
