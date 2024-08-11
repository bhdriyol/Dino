import 'package:dino_merlin/Pages/User/other_user_profile_page.dart';
import 'package:flutter/material.dart';

class StoriesCard extends StatelessWidget {
  const StoriesCard({
    super.key,
    required this.title,
    required this.content,
    required this.authorUsername,
    required this.authorProfilePic,
    required this.authorId,
    required this.authorBiography,
  });

  final String title;
  final String content;
  final String authorUsername;
  final String authorProfilePic;
  final String authorId;
  final String authorBiography;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TitleTextStyle().titleTextStyle,
              ),
              const SizedBox(height: 5),
              Text(
                content,
                style: ContentTextStyle().contentTextStyle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => OtherUserProfilePage(
                              userId: authorId,
                              nickname: authorUsername,
                              profilePictureUrl: authorProfilePic,
                              biography: authorBiography,
                            )),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      authorUsername,
                      style: UsernameTextStyle().usernameTextStyle,
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(authorProfilePic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
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
