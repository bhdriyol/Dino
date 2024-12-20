import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dino_merlin/Pages/Feed/story_detail_page.dart';
import 'package:dino_merlin/Pages/User/other_user_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedStoriesCard extends StatefulWidget {
  const FeedStoriesCard({
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
  _StoriesCardState createState() => _StoriesCardState();
}

class _StoriesCardState extends State<FeedStoriesCard> {
  bool isLiked = false;
  bool isDisliked = false;
  bool isSaved = false;
  int likeCount = 0;
  int dislikeCount = 0;
  int saveCount = 0;

  String authorUsername = '';
  String authorProfilePic = '';
  String authorBiography = '';
  int followersCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchAuthorDetails();
    _checkUserInteraction();
  }

  Future<void> _fetchAuthorDetails() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.authorId)
        .get();

    if (userDoc.exists) {
      setState(() {
        authorUsername = userDoc['username'] ?? '';
        authorProfilePic = userDoc['profilePic'] ?? '';
        authorBiography = userDoc['biography'] ?? '';
        followersCount = userDoc['followers']?.length ?? 0;
      });
    }
  }

  Future<void> _checkUserInteraction() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot storyDoc = await FirebaseFirestore.instance
        .collection('stories')
        .doc(widget.storyId)
        .get();

    if (storyDoc.exists) {
      Map<String, dynamic> storyData = storyDoc.data() as Map<String, dynamic>;
      List<dynamic> likes = storyData['likes'] ?? [];
      List<dynamic> dislikes = storyData['dislikes'] ?? [];
      List<dynamic> saves = storyData['saves'] ?? [];

      setState(() {
        isLiked = likes.contains(currentUserId);
        isDisliked = dislikes.contains(currentUserId);
        isSaved = saves.contains(currentUserId);
        likeCount = likes.length;
        dislikeCount = dislikes.length;
        saveCount = saves.length;
      });
    }
  }

  Future<void> _toggleLike() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference storyRef =
        FirebaseFirestore.instance.collection('stories').doc(widget.storyId);

    if (isLiked) {
      storyRef.update({
        'likes': FieldValue.arrayRemove([currentUserId]),
      });
      setState(() {
        isLiked = false;
        likeCount--;
      });
    } else {
      if (isDisliked) {
        storyRef.update({
          'dislikes': FieldValue.arrayRemove([currentUserId]),
        });
        setState(() {
          isDisliked = false;
          dislikeCount--;
        });
      }
      storyRef.update({
        'likes': FieldValue.arrayUnion([currentUserId]),
      });
      setState(() {
        isLiked = true;
        likeCount++;
      });
    }
  }

  Future<void> _toggleDislike() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference storyRef =
        FirebaseFirestore.instance.collection('stories').doc(widget.storyId);

    if (isDisliked) {
      storyRef.update({
        'dislikes': FieldValue.arrayRemove([currentUserId]),
      });
      setState(() {
        isDisliked = false;
        dislikeCount--;
      });
    } else {
      if (isLiked) {
        storyRef.update({
          'likes': FieldValue.arrayRemove([currentUserId]),
        });
        setState(() {
          isLiked = false;
          likeCount--;
        });
      }
      storyRef.update({
        'dislikes': FieldValue.arrayUnion([currentUserId]),
      });
      setState(() {
        isDisliked = true;
        dislikeCount++;
      });
    }
  }

  Future<void> _toggleSave() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference storyRef =
        FirebaseFirestore.instance.collection('stories').doc(widget.storyId);
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);

    if (isSaved) {
      storyRef.update({
        'saves': FieldValue.arrayRemove([currentUserId]),
      });

      userRef.update({
        'savedStories': FieldValue.arrayRemove([widget.storyId]),
      });

      setState(() {
        isSaved = false;
        saveCount--;
      });
    } else {
      storyRef.update({
        'saves': FieldValue.arrayUnion([currentUserId]),
      });

      userRef.update({
        'savedStories': FieldValue.arrayUnion([widget.storyId]),
      });

      setState(() {
        isSaved = true;
        saveCount++;
      });
    }
  }

  void navigateToUserProfile(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => OtherUserProfilePage(
                userId: widget.authorId,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StoryDetailPage(
                title: widget.title,
                content: widget.content,
                authorUsername: authorUsername,
                authorProfilePic: authorProfilePic,
                storyId: widget.storyId,
                authorId: widget.authorId,
                onInteractionUpdate: _checkUserInteraction,
              ),
            ),
          );
          _checkUserInteraction();
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
                GestureDetector(
                  onTap: () {
                    navigateToUserProfile(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: _toggleLike,
                            icon: Icon(
                              isLiked
                                  ? Icons.thumb_up_alt
                                  : Icons.thumb_up_alt_outlined,
                              color: isLiked ? Colors.deepPurple : null,
                            ),
                          ),
                          Text(likeCount.toString(),
                              style: CountTextStyle().countTextStyle),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: _toggleDislike,
                            icon: Icon(
                              isDisliked
                                  ? Icons.thumb_down_alt
                                  : Icons.thumb_down_alt_outlined,
                              color: isDisliked ? Colors.red : null,
                            ),
                          ),
                          Text(dislikeCount.toString(),
                              style: CountTextStyle().countTextStyle),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: _toggleSave,
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? Colors.green : null,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            authorUsername,
                            style: UsernameTextStyle().usernameTextStyle,
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: authorProfilePic.isNotEmpty &&
                                    authorProfilePic.startsWith('http')
                                ? NetworkImage(authorProfilePic)
                                : const AssetImage(
                                        'assets/images/default_profile.png')
                                    as ImageProvider, // Default image
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
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

class CountTextStyle {
  TextStyle countTextStyle = const TextStyle(
      fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white);
}
