import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dino_merlin/Pages/Auth/login_page.dart';
import 'package:dino_merlin/Widgets/user_stories_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  String? profilePictureUrl;
  String? nickname;
  String? biography;
  bool isLoading = false;

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
        nickname = userDoc['username'];
        biography = userDoc["biography"];
        profilePictureUrl = userDoc['profilePic'];
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        isLoading = true;
      });
      await _uploadImage(File(pickedFile.path));
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _uploadImage(File image) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child('$userId.jpg');

    try {
      await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profilePic': downloadUrl,
      });

      setState(() {
        profilePictureUrl = downloadUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  void logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logOut(context),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError) {
            return Center(
                child: Text('Error: ${userSnapshot.error.toString()}'));
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text('User data not found.'));
          }

          final userDoc = userSnapshot.data!;
          final authorId = userDoc['randomId'];
          final profilePictureUrl = userDoc['profilePic'] ?? '';

          return Column(
            mainAxisSize: MainAxisSize
                .min, // Column'un çocuklarına göre boyutlanmasını sağla
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: profilePictureUrl.isNotEmpty
                                ? NetworkImage(profilePictureUrl)
                                : null,
                            child: profilePictureUrl.isEmpty
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                          if (isLoading)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      nickname ?? 'No nickname',
                      style: NickNameTextStyle().nickNameTextStyle,
                    ),
                  ],
                ),
              ),
              Text(biography ?? "No biography yet."),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('stories')
                    .where('authorId', isEqualTo: authorId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (ctx, storiesSnapshot) {
                  if (storiesSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (storiesSnapshot.hasError) {
                    return Center(
                        child:
                            Text('Error: ${storiesSnapshot.error.toString()}'));
                  }

                  if (!storiesSnapshot.hasData ||
                      storiesSnapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No stories found.'));
                  }

                  final userStoriesDocs = storiesSnapshot.data!.docs;

                  return Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Your stories: ${userStoriesDocs.length}",
                              style:
                                  YourStoriesTextStyle().yourStoriesTextStyle,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: userStoriesDocs.length,
                            itemBuilder: (ctx, index) {
                              return UserStoriesCard(
                                title: userStoriesDocs[index]['title'],
                                content: userStoriesDocs[index]['content'],
                                authorUsername: userStoriesDocs[index]
                                    ['authorUsername'],
                                authorProfilePic: userStoriesDocs[index]
                                    ['authorProfilePic'],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class NickNameTextStyle {
  TextStyle nickNameTextStyle =
      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
}

class YourStoriesTextStyle {
  TextStyle yourStoriesTextStyle =
      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
}