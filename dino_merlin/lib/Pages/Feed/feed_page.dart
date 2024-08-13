import 'package:dino_merlin/Pages/Feed/new_story_page.dart';
import 'package:dino_merlin/Widgets/feed_stories_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                    return StoriesCard(
                      key: ValueKey(storiesDocs[index].id),
                      title: storiesDocs[index]["title"],
                      content: storiesDocs[index]["content"],
                      authorUsername: storiesDocs[index]["authorUsername"],
                      authorProfilePic: storiesDocs[index]["authorProfilePic"],
                      authorId: storiesDocs[index]["authorId"],
                      authorBiography: storiesDocs[index]["authorBiography"],
                      storyId: storiesDocs[index]["storyId"],
                    );
                  },
                );
              },
            ),
            //! New Stories Tab
            const Center(child: Text("Nothing to see.")),
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
