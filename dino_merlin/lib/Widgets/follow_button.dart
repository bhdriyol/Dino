import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowButton extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;

  const FollowButton(
      {Key? key, required this.currentUserId, required this.otherUserId})
      : super(key: key);

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isFollowed = false;

  @override
  void initState() {
    super.initState();
    checkIfFollowed();
  }

  Future<void> checkIfFollowed() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .get();

    List<dynamic> followingList = userSnapshot.get('following');
    setState(() {
      isFollowed = followingList.contains(widget.otherUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          isFollowed ? Colors.deepPurple : Colors.white,
        ),
      ),
      onPressed: () async {
        setState(() {
          isFollowed = !isFollowed;
        });

        if (isFollowed) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.currentUserId)
              .update({
            'following': FieldValue.arrayUnion([widget.otherUserId]),
          });
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.otherUserId)
              .update({
            'followers': FieldValue.arrayUnion([widget.currentUserId]),
          });
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.currentUserId)
              .update({
            'following': FieldValue.arrayRemove([widget.otherUserId]),
          });
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.otherUserId)
              .update({
            'followers': FieldValue.arrayRemove([widget.currentUserId]),
          });
        }
      },
      child: Text(
        isFollowed ? 'Followed' : 'Follow',
        style: TextStyle(
          color: isFollowed ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
