import 'package:flutter/material.dart';

class StoryDetailPage extends StatelessWidget {
  const StoryDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.authorUsername,
    required this.authorProfilePic,
  });
  final String title;
  final String content;
  final String authorUsername;
  final String authorProfilePic;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TitleTextStyle().titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                content,
                style: ContentTextStyle().contentTextStyle,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.thumb_up_alt_outlined),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.thumb_down_alt_outlined),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert_outlined),
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
                        backgroundImage: NetworkImage(authorProfilePic),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(),
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
  TextStyle contentTextStyle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey);
}

class UsernameTextStyle {
  TextStyle usernameTextStyle = const TextStyle(
      fontWeight: FontWeight.w600, fontSize: 18, color: Colors.deepPurple);
}
