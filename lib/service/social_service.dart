import '../models/social_models.dart';

class SocialService {
  // Artist Profile setup
  final UserProfile artistProfile = UserProfile(
    id: 'artist_01',
    username: 'Odi Wa Turkana',
    location: 'Kakuma, Turkana, Northern Kenya',
    bio: 'Official App | Bringing authentic Turkana sound & culture to the world. 🇰🇪',
    avatarUrl: 'https://via.placeholder.com/150',
    followersCount: 1240,
  );

  final List<Post> _posts = [
    Post(
      id: 'post_1',
      authorName: 'Odi Wa Turkana',
      authorLocation: 'Kakuma, Turkana',
      content: 'New hit dropped live from Kakuma! Check out my latest tracks in the feed. 🎶🌴',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 45,
      comments: ['Fire track! 🔥', 'Turkana to the world! 🙌'],
    ),
  ];

  List<Post> get posts => _posts;

  void addPost(String content) {
    _posts.insert(
      0,
      Post(
        id: DateTime.now().toString(),
        authorName: artistProfile.username,
        authorLocation: artistProfile.location,
        content: content,
        timestamp: DateTime.now(),
      ),
    );
  }

  void toggleLike(Post post) {
    post.likes++;
  }

  void addComment(Post post, String comment) {
    post.comments.add(comment);
  }

  void followArtist() {
    artistProfile.followersCount++;
  }
}