import 'package:flutter/material.dart';

class FollowButton extends StatefulWidget {
  const FollowButton({Key? key}) : super(key: key);

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isFollowed = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          isFollowed ? Colors.deepPurple : Colors.white,
        ),
      ),
      onPressed: () {
        setState(() {
          isFollowed = !isFollowed;
        });
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
