import 'package:dino_merlin/Pages/Feed/story_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserStoriesCard extends StatefulWidget {
  const UserStoriesCard({
    super.key,
    required this.title,
    required this.content,
    required this.authorId,
    required this.storyId,
  });

  final String title;
  final String content;
  final String authorId;
  final String storyId;

  @override
  State<UserStoriesCard> createState() => _UserStoriesCardState();
}

class _UserStoriesCardState extends State<UserStoriesCard> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.authorId)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userSnapshot.hasError) {
          return Center(child: Text('Error: ${userSnapshot.error}'));
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text('User not found.'));
        }

        final userDoc = userSnapshot.data!;
        final authorUsername = userDoc['username'] ?? 'Unknown';
        final authorProfilePic = userDoc['profilePic'] ?? '';

        return IntrinsicHeight(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StoryDetailPage(
                    title: widget.title,
                    content: widget.content,
                    authorUsername: authorUsername,
                    authorProfilePic: authorProfilePic,
                    storyId: widget.storyId,
                    onInteractionUpdate: () {},
                    authorId: widget.authorId,
                  ),
                ),
              );
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TitleTextStyle().titleTextStyle,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.content,
                      style: ContentTextStyle().contentTextStyle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          authorUsername,
                          style: UsernameTextStyle().usernameTextStyle,
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: authorProfilePic.isNotEmpty
                              ? NetworkImage(authorProfilePic)
                              : null,
                          child: authorProfilePic.isEmpty
                              ? const Icon(Icons.person, size: 20)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TitleTextStyle {
  TextStyle titleTextStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );
}

class ContentTextStyle {
  TextStyle contentTextStyle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey);
}

class UsernameTextStyle {
  TextStyle usernameTextStyle = const TextStyle(
      fontWeight: FontWeight.w600, fontSize: 15, color: Colors.deepPurple);
}
