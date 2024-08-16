import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController biographyController = TextEditingController();

  String? email;
  String? username;
  String? biography;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      setState(() {
        email = userDoc['email'];
        username = userDoc['username'];
        biography = userDoc['biography'];
        biographyController.text = biography ?? '';
      });
    }
  }

  Future<void> _saveBiography() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      isSaving = true;
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'biography': biographyController.text});

    setState(() {
      biography = biographyController.text;
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Biography updated successfully')),
    );

    Navigator.pop(context, true);
  }

  Future<void> _logOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: TextEditingController(text: email),
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: username),
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: biographyController,
              decoration: const InputDecoration(
                labelText: 'Biography',
              ),
              maxLength: 30,
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveBiography,
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _logOut,
                child: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
