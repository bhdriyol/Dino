import 'package:dino_merlin/Pages/Feed/new_story_page.dart';
import 'package:dino_merlin/Widgets/feed_stories_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedPage extends StatelessWidget {
  FeedPage({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText().titleText,
        centerTitle: true,
      ),
      body: StreamBuilder(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NewStoryPage(),
          ));
        },
        child: const Icon(Icons.add),
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
