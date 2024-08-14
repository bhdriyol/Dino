import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dino_merlin/Pages/User/other_user_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StoryDetailPage extends StatefulWidget {
  const StoryDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.authorUsername,
    required this.authorProfilePic,
    required this.storyId,
    required this.onInteractionUpdate,
    required this.authorId,
  });

  final String title;
  final String content;
  final String authorUsername;
  final String authorId;
  final String authorProfilePic;
  final String storyId;
  final Function onInteractionUpdate;

  @override
  _StoryDetailPageState createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  bool isLiked = false;
  bool isDisliked = false;
  bool isSaved = false;
  int likeCount = 0;
  int dislikeCount = 0;
  int saveCount = 0;

  @override
  void initState() {
    super.initState();
    _checkUserInteraction();
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

  void navigateToUserProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OtherUserProfilePage(
          userId: widget.authorId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TitleTextStyle().titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Text(
                widget.content,
                style: ContentTextStyle().contentTextStyle,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _toggleLike();
                          widget.onInteractionUpdate();
                        },
                        icon: Icon(
                          isLiked
                              ? Icons.thumb_up_alt
                              : Icons.thumb_up_alt_outlined,
                          color: isLiked ? Colors.blue : null,
                        ),
                      ),
                      Text(likeCount.toString(),
                          style: CountTextStyle().countTextStyle),
                      IconButton(
                        onPressed: () {
                          _toggleDislike();
                          widget.onInteractionUpdate();
                        },
                        icon: Icon(
                          isDisliked
                              ? Icons.thumb_down_alt
                              : Icons.thumb_down_alt_outlined,
                          color: isDisliked ? Colors.red : null,
                        ),
                      ),
                      Text(dislikeCount.toString(),
                          style: CountTextStyle().countTextStyle),
                      IconButton(
                        onPressed: () {
                          _toggleSave();
                          widget.onInteractionUpdate();
                        },
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? Colors.green : null,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      navigateToUserProfile();
                    },
                    child: Row(
                      children: [
                        Text(
                          widget.authorUsername,
                          style: UsernameTextStyle().usernameTextStyle,
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              NetworkImage(widget.authorProfilePic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(
                thickness: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TitleTextStyle {
  TextStyle titleTextStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 23,
  );
}

class ContentTextStyle {
  TextStyle contentTextStyle =
      const TextStyle(fontSize: 18, color: Colors.grey);
}

class UsernameTextStyle {
  TextStyle usernameTextStyle = const TextStyle(
      fontWeight: FontWeight.w600, fontSize: 18, color: Colors.deepPurple);
}

class CountTextStyle {
  TextStyle countTextStyle = const TextStyle(
      fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white);
}
