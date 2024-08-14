import 'package:flutter/material.dart';

class FollowsCard extends StatelessWidget {
  final String profilePic;
  final String username;
  final VoidCallback onTap;

  const FollowsCard({
    super.key,
    required this.profilePic,
    required this.username,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.10),
        child: SizedBox(
          height: 70,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircleAvatar(
                      backgroundImage: profilePic.isNotEmpty
                          ? NetworkImage(profilePic)
                          : null,
                      child:
                          profilePic.isEmpty ? const Icon(Icons.person) : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      username,
                      style: UserNameTextStyle().usernameTextStyle,
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 1,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class UserNameTextStyle {
  TextStyle usernameTextStyle = const TextStyle(
      fontSize: 18,
      overflow: TextOverflow.ellipsis,
      fontWeight: FontWeight.w500);
}
