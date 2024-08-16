import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dino_merlin/Pages/Auth/login_page.dart';
import 'package:dino_merlin/Pages/Settings/settings_page.dart';
import 'package:dino_merlin/Pages/User/follows_page.dart';
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

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  String? profilePictureUrl;
  String? nickname;
  String? biography;
  bool isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _tabController = TabController(length: 2, vsync: this);
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

  void navigateToFollowsPage(BuildContext context, int initialTabIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FollowsPage(
            initialTabIndex: initialTabIndex,
            username: nickname ?? "No nickname"),
      ),
    );
  }

  void navigateToSettingsPage(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );

    if (result == true) {
      _loadUserData();
    }
  }

  void logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  navigateToSettingsPage(context);
                }),
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
            final profilePictureUrl = userDoc['profilePic'] ?? '';

            return Column(
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nickname ?? 'No nickname',
                            style: NickNameTextStyle().nickNameTextStyle,
                          ),
                          Text(
                            biography ?? "No biography yet.",
                            style: const TextStyle(fontSize: 14),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: Future.wait([
                      FirebaseFirestore.instance
                          .collection('stories')
                          .where('authorId',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                          .get()
                          .then((snapshot) => {
                                'sharedCount': snapshot.docs.length,
                              }),
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get()
                          .then((snapshot) => {
                                'followingCount':
                                    (snapshot.data()?['following'] as List?)
                                            ?.length ??
                                        0,
                                'followersCount':
                                    (snapshot.data()?['followers'] as List?)
                                            ?.length ??
                                        0,
                              })
                    ]).then((results) => {
                          'sharedCount': results[0]['sharedCount'],
                          'followingCount': results[1]['followingCount'],
                          'followersCount': results[1]['followersCount']
                        }),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      final data = snapshot.data;
                      final sharedCount = data?['sharedCount'] ?? 0;
                      final followingCount = data?['followingCount'] ?? 0;
                      final followersCount = data?['followersCount'] ?? 0;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Shared: $sharedCount',
                          ),
                          const SizedBox(
                            height: 20,
                            child: VerticalDivider(
                              thickness: 2,
                              color: Colors.grey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => navigateToFollowsPage(context, 0),
                            child: Column(
                              children: [
                                Text('Followers: $followersCount'),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                            child: VerticalDivider(
                              thickness: 2,
                              color: Colors.grey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => navigateToFollowsPage(context, 1),
                            child: Column(
                              children: [
                                Text('Following: $followingCount'),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
                const Divider(thickness: 2, color: Colors.grey),
                const SizedBox(
                  height: 10,
                ),
                TabBar(
                  dividerHeight: 0,
                  controller: _tabController,
                  labelColor: Colors.deepPurple,
                  indicatorColor: Colors.deepPurple,
                  tabs: const [
                    Tab(text: 'Your Stories'),
                    Tab(text: 'Saved Stories'),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      //! Your Stories Tab
                      RefreshIndicator(
                        onRefresh: refresh,
                        child: FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('stories')
                              .where('authorId',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            final stories = snapshot.data?.docs ?? [];
                            return ListView.builder(
                              itemCount: stories.length,
                              itemBuilder: (context, index) {
                                final story = stories[index];
                                final storyData =
                                    story.data() as Map<String, dynamic>;
                                return UserStoriesCard(
                                  title: storyData['title'] ?? 'No Title',
                                  content: storyData['content'] ?? 'No Content',
                                  authorId: storyData['authorId'],
                                  storyId: storyData["storyId"],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      //! Saved Stories Tab
                      RefreshIndicator(
                        onRefresh: refresh,
                        child: FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            final userDoc = snapshot.data;
                            final savedStoriesIds =
                                (userDoc?['savedStories'] as List?)
                                        ?.cast<String>() ??
                                    [];
                            return FutureBuilder<List<DocumentSnapshot>>(
                              future: Future.wait(
                                savedStoriesIds.map(
                                  (storyId) => FirebaseFirestore.instance
                                      .collection('stories')
                                      .doc(storyId)
                                      .get(),
                                ),
                              ),
                              builder: (context, savedStoriesSnapshot) {
                                if (savedStoriesSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (savedStoriesSnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Error: ${savedStoriesSnapshot.error}'));
                                }

                                final savedStories =
                                    savedStoriesSnapshot.data ?? [];
                                return ListView.builder(
                                  itemCount: savedStories.length,
                                  itemBuilder: (context, index) {
                                    final story = savedStories[index];
                                    final storyData =
                                        story.data() as Map<String, dynamic>;
                                    return UserStoriesCard(
                                      title: storyData['title'] ?? 'No Title',
                                      content:
                                          storyData['content'] ?? 'No Content',
                                      authorId: storyData['authorId'],
                                      storyId: storyData["storyId"],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class NickNameTextStyle {
  TextStyle nickNameTextStyle =
      const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
}

class FollowsButtonStyle {
  TextStyle followsButtonStyle =
      const TextStyle(color: Colors.white, fontWeight: FontWeight.normal);
}
