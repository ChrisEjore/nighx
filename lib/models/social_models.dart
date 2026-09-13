class UserProfile {
  final String id;
  final String username;
  final String location;
  final String bio;
  final String avatarUrl;
  int followersCount;

  UserProfile({
    required this.id,
    required this.username,
    required this.location,
    required this.bio,
    required this.avatarUrl,
    this.followersCount = 0,
  });
}

class Post {
  final String id;
  final String authorName;
  final String authorLocation;
  final String content;
  final DateTime timestamp;
  int likes;
  List<String> comments;

  Post({
    required this.id,
    required this.authorName,
    required this.authorLocation,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    List<String>? comments,
  }) : comments = comments ?? [];
}