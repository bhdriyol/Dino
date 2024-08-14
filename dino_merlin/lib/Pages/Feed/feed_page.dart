import 'package:dino_merlin/Pages/Feed/new_story_page.dart';
import 'package:dino_merlin/Widgets/feed_stories_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedPage extends StatefulWidget {
  FeedPage({
    super.key,
  });

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: AppBarTitleText().titleText,
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.deepPurple,
            dividerHeight: 0,
            tabs: [
              Tab(child: FeedText().feedText),
              Tab(child: FollowedText().followedText),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            //! Main Feed Tab
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('stories')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('An error occurred.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No stories found.'));
                }

                final storiesDocs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: storiesDocs.length,
                  itemBuilder: (ctx, index) {
                    return FeedStoriesCard(
                      key: ValueKey(storiesDocs[index].id),
                      title: storiesDocs[index]["title"],
                      content: storiesDocs[index]["content"],
                      authorId: storiesDocs[index]["authorId"],
                      storyId: storiesDocs[index]["storyId"],
                    );
                  },
                );
              },
            ),
            //! Followed Stories Tab
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUserId)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return const Center(child: Text('An error occurred.'));
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const Center(
                      child: Text('No followed stories found.'));
                }

                List<String> followedUserIds =
                    List<String>.from(userSnapshot.data!['following'] ?? []);

                if (followedUserIds.isEmpty) {
                  return const Center(
                      child: Text('No followed stories found.'));
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('stories')
                      .where('authorId', whereIn: followedUserIds)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder:
                      (ctx, AsyncSnapshot<QuerySnapshot> followedSnapshot) {
                    if (followedSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (followedSnapshot.hasError) {
                      return const Center(child: Text('An error occurred.'));
                    }

                    if (!followedSnapshot.hasData ||
                        followedSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No followed found.'));
                    }

                    final followedStoriesDocs = followedSnapshot.data!.docs;
                    return ListView.builder(
                      itemCount: followedStoriesDocs.length,
                      itemBuilder: (ctx, index) {
                        return FeedStoriesCard(
                          key: ValueKey(followedStoriesDocs[index].id),
                          title: followedStoriesDocs[index]["title"],
                          content: followedStoriesDocs[index]["content"],
                          authorId: followedStoriesDocs[index]["authorId"],
                          storyId: followedStoriesDocs[index]["storyId"],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NewStoryPage(),
            ));
            setState(() {});
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class AppBarTitleText {
  Text titleText = const Text(
    "DİNO",
    style:
        TextStyle(fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: 10),
  );
}

class FeedText {
  Text feedText = const Text(
    "Feed",
    style: TextStyle(
      fontSize: 18,
    ),
  );
}

class FollowedText {
  Text followedText = const Text(
    "Followed",
    style: TextStyle(
      fontSize: 18,
    ),
  );
}
