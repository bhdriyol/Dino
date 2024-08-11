import 'package:dino_merlin/Widgets/user_stories_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String userId;
  final String profilePictureUrl;
  final String nickname;
  final String biography;
  const OtherUserProfilePage(
      {super.key,
      required this.userId,
      required this.nickname,
      required this.profilePictureUrl,
      required this.biography});

  @override
  _OtherUserProfilePageState createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        print(widget.userId);
      } else {
        print('User with ID ${widget.userId} does not exist.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: widget.profilePictureUrl != null
                              ? NetworkImage(widget.profilePictureUrl!)
                              : null,
                          child: widget.profilePictureUrl == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          widget.nickname ?? 'No nickname',
                          style: NickNameTextStyle().nickNameTextStyle,
                        ),
                      ],
                    ),
                  ),
                  Text(widget.biography ?? "No biography yet."),
                  const SizedBox(height: 10),
                  const Divider(height: 10),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('stories')
                        .where('authorId', isEqualTo: widget.userId)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (ctx, storiesSnapshot) {
                      if (storiesSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (storiesSnapshot.hasError) {
                        return Center(
                            child: Text(
                                'Error: ${storiesSnapshot.error.toString()}'));
                      }

                      if (!storiesSnapshot.hasData ||
                          storiesSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No stories found.'));
                      }

                      final userStoriesDocs = storiesSnapshot.data!.docs;

                      return Column(
                        children: [
                          Text(
                            "Total stories: ${userStoriesDocs.length}",
                            style: AllStoriesTextStyle().allStoriesTextStyle,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
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
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class NickNameTextStyle {
  TextStyle nickNameTextStyle =
      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
}

class AllStoriesTextStyle {
  TextStyle allStoriesTextStyle =
      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
}
