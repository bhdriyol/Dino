import 'package:dino_merlin/Widgets/follows_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'other_user_profile_page.dart';

class FollowsPage extends StatefulWidget {
  final int initialTabIndex;
  final String username;

  const FollowsPage({
    super.key,
    required this.initialTabIndex,
    required this.username,
  });

  @override
  _FollowsPageState createState() => _FollowsPageState();
}

class _FollowsPageState extends State<FollowsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  Future<List<DocumentSnapshot>> _getUsersByIds(List<String> userIds) async {
    return await Future.wait(userIds.map((userId) {
      return FirebaseFirestore.instance.collection('users').doc(userId).get();
    }));
  }

  Future<void> refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Followers'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          //! Followers Tab
          RefreshIndicator(
            onRefresh: refresh,
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final userDoc = snapshot.data;
                final followersIds =
                    (userDoc?['followers'] as List?)?.cast<String>() ?? [];

                if (followersIds.isEmpty) {
                  return const Center(child: Text('No followers found.'));
                }

                return FutureBuilder<List<DocumentSnapshot>>(
                  future: _getUsersByIds(followersIds),
                  builder: (context, usersSnapshot) {
                    if (usersSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (usersSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${usersSnapshot.error}'));
                    }

                    final followers = usersSnapshot.data ?? [];

                    return ListView.builder(
                      itemCount: followers.length,
                      itemBuilder: (context, index) {
                        final follower = followers[index];
                        final followerData =
                            follower.data() as Map<String, dynamic>;
                        return FollowsCard(
                          profilePic: followerData['profilePic'] ?? '',
                          username: followerData['username'] ?? 'No Username',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtherUserProfilePage(
                                  userId: follower.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          //! Following Tab
          RefreshIndicator(
            onRefresh: refresh,
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final userDoc = snapshot.data;
                final followingIds =
                    (userDoc?['following'] as List?)?.cast<String>() ?? [];

                if (followingIds.isEmpty) {
                  return const Center(child: Text('No following found.'));
                }

                return FutureBuilder<List<DocumentSnapshot>>(
                  future: _getUsersByIds(followingIds),
                  builder: (context, usersSnapshot) {
                    if (usersSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (usersSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${usersSnapshot.error}'));
                    }

                    final following = usersSnapshot.data ?? [];

                    return ListView.builder(
                      itemCount: following.length,
                      itemBuilder: (context, index) {
                        final followingUser = following[index];
                        final followingUserData =
                            followingUser.data() as Map<String, dynamic>;
                        return FollowsCard(
                          profilePic: followingUserData['profilePic'] ?? '',
                          username:
                              followingUserData['username'] ?? 'No Username',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtherUserProfilePage(
                                  userId: followingUser.id,
                                ),
                              ),
                            );
                          },
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
    );
  }
}
