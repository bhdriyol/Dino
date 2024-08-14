import 'package:dino_merlin/Widgets/follow_button.dart';
import 'package:dino_merlin/Widgets/user_stories_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String userId;

  const OtherUserProfilePage({
    super.key,
    required this.userId,
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

  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: loadUserData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: userDoc?['profilePic'] != null &&
                                  userDoc!['profilePic'].isNotEmpty
                              ? NetworkImage(userDoc!['profilePic'])
                              : null,
                          child: userDoc?['profilePic'] == null ||
                                  userDoc!['profilePic'].isEmpty
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    userDoc?['username'] ?? 'Unknown',
                                    style:
                                        NickNameTextStyle().nickNameTextStyle,
                                  ),
                                  if (currentUserId != widget.userId)
                                    FollowButton(
                                      currentUserId: currentUserId,
                                      otherUserId: widget.userId,
                                    ),
                                ],
                              ),
                              Text(userDoc?['biography'] ?? 'No biography'),
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
                      Text('Following: ${userDoc?['following']?.length ?? 0}'),
                      const SizedBox(
                        height: 20,
                        child: VerticalDivider(
                          thickness: 2,
                          color: Colors.grey,
                        ),
                      ),
                      Text('Followers: ${userDoc?['followers']?.length ?? 0}'),
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
                          return const Center(
                              child: CircularProgressIndicator());
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
                                    authorId: userStoriesDocs[index]
                                        ["authorId"],
                                    storyId: userStoriesDocs[index]["storyId"],
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
      ),
    );
  }
}

class NickNameTextStyle {
  TextStyle nickNameTextStyle =
      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
}
