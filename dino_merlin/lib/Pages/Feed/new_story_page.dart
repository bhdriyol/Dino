import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dino_merlin/Pages/Auth/Widgets/entry_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewStoryPage extends StatefulWidget {
  NewStoryPage({super.key});

  @override
  _NewStoryPageState createState() => _NewStoryPageState();
}

class _NewStoryPageState extends State<NewStoryPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  String titleError = '';
  String contentError = '';

  void _addStory() async {
    setState(() {
      titleError = titleController.text.isEmpty ? 'Title is required' : '';
      contentError =
          contentController.text.isEmpty ? 'Content is required' : '';
    });

    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      return;
    }

    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (!userDoc.exists) {
        print("User document does not exist.");
        return;
      }

      String authorUsername = userDoc["username"];
      String authorProfilePic = userDoc["profilePic"];
      String authorBiography = userDoc["biography"];

      String storyId =
          FirebaseFirestore.instance.collection('stories').doc().id;

      await FirebaseFirestore.instance.collection('stories').doc(storyId).set({
        'storyId': storyId,
        'title': titleController.text,
        'content': contentController.text,
        'authorId': currentUserId,
        "authorUsername": authorUsername,
        "authorProfilePic": authorProfilePic,
        "authorBiography": authorBiography,
        "likes": [],
        "dislikes": [],
        'timestamp': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'shares': FieldValue.arrayUnion([storyId])
      });
      Navigator.of(context).pop();
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Story'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                maxLength: 40,
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  errorText: titleError.isNotEmpty ? titleError : null,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                maxLines: null,
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  errorText: contentError.isNotEmpty ? contentError : null,
                ),
              ),
              const SizedBox(height: 20),
              EntryButton(
                onPressed: _addStory,
                buttonText: "Submit",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
