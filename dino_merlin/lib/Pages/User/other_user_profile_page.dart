import 'package:dino_merlin/Widgets/follow_button.dart';
import 'package:dino_merlin/Widgets/user_stories_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String userId;
  final String profilePictureUrl;
  final String nickname;
  final String biography;

  const OtherUserProfilePage({
    super.key,
    required this.userId,
    required this.nickname,
    required this.profilePictureUrl,
    required this.biography,
  });

  @override
  _OtherUserProfilePageState createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  bool isLoading = true;
  Map<String, dynamic>? userDoc;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          userDoc = userSnapshot.data();
          isLoading = false;
        });
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: widget.profilePictureUrl.isNotEmpty
                            ? NetworkImage(widget.profilePictureUrl)
                            : null,
                        child: widget.profilePictureUrl.isEmpty
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.nickname,
                                  style: NickNameTextStyle().nickNameTextStyle,
                                ),
                                const FollowButton(),
                              ],
                            ),
                            Text(widget.biography),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('stories')
                          .where('authorId', isEqualTo: widget.userId)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        final sharedCount = snapshot.data?.docs.length ?? 0;

                        return Text(
                          'Shared: $sharedCount',
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20,
                      child: VerticalDivider(
                        thickness: 2,
                        color: Colors.grey,
                      ),
                    ),
                    Text('Following: ${userDoc?['following'] ?? 0}'),
                    const SizedBox(
                      height: 20,
                      child: VerticalDivider(
                        thickness: 2,
                        color: Colors.grey,
                      ),
                    ),
                    Text('Followers: ${userDoc?['followers'] ?? 0}'),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(thickness: 2, color: Colors.grey),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
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
                      );
                    },
                  ),
                ),
              ],
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
