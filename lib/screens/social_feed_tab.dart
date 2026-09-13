import 'package:flutter/material.dart';
import '../models/social_models.dart';
import '../service/database.dart';

class SocialFeedTab extends StatefulWidget {
  const SocialFeedTab({super.key});

  @override
  State<SocialFeedTab> createState() => _SocialFeedTabState();
}

class _SocialFeedTabState extends State<SocialFeedTab> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _postController = TextEditingController();
  bool _isLoading = false;

  // Pre-populated default posts for initial display
  List<Post> _feedPosts = [
    Post(
      id: 'post_1',
      authorName: 'Odi Wa Turkana',
      authorLocation: 'Kakuma 1, Turkana',
      content: 'New audio track "Kakuma Anthem" dropping this Friday! Big shoutout to all fans supporting Northern Kenya music culture. 🇰🇪🔥',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      likes: 184,
      comments: ['Can\'t wait for this classic! 🔥', 'Turkana to the world! ✊'],
    ),
    Post(
      id: 'post_2',
      authorName: 'Odi Wa Turkana',
      authorLocation: 'Kakuma Cultural Center',
      content: 'Live concert highlights from the Kakuma Cultural Festival are now streaming in the Video tab. Go check them out!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      likes: 245,
      comments: ['The energy was unmatched! ⚡'],
    ),
    Post(
      id: 'post_3',
      authorName: 'Odi Wa Turkana',
      authorLocation: 'Lodwar / Kakuma Road',
      content: 'On the road for the Northern Kenya Tour. Next stop: Lodwar! See you all soon. 🚌🎤',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      likes: 312,
      comments: ['Welcome to Lodwar brother!', 'Safe travels!'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPostsFromBackend();
  }

  // Fetch real-time posts from PostgreSQL server if connected
  Future<void> _loadPostsFromBackend() async {
    setState(() => _isLoading = true);
    List<Post> dbPosts = await _dbHelper.fetchPosts();
    if (dbPosts.isNotEmpty) {
      setState(() {
        _feedPosts = dbPosts;
      });
    }
    setState(() => _isLoading = false);
  }

  // Handle new post creation
  Future<void> _createNewPost() async {
    if (_postController.text.trim().isEmpty) return;

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'Odi Wa Turkana',
      authorLocation: 'Kakuma, Turkana',
      content: _postController.text.trim(),
      timestamp: DateTime.now(),
      likes: 0,
      comments: [],
    );

    // Save locally to UI state
    setState(() {
      _feedPosts.insert(0, newPost);
    });

    // Sync with PostgreSQL
    await _dbHelper.insertPost(newPost);
    _postController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadPostsFromBackend,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // --- Artist Quick Profile Header ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  border: Border(bottom: BorderSide(color: Colors.deepOrange.shade100)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.deepOrange,
                      child: Icon(Icons.person, size: 35, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Odi Wa Turkana',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '📍 Kakuma, Turkana, Northern Kenya',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Text(
                            'Official Community & Music Feed',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- Post Creator Input ---
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _postController,
                            decoration: const InputDecoration(
                              hintText: 'Share updates from Kakuma...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.deepOrange),
                          onPressed: _createNewPost,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),

              // --- Feed Stream ---
              _isLoading
                  ? const Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: Colors.deepOrange),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _feedPosts.length,
                itemBuilder: (context, index) {
                  final post = _feedPosts[index];
                  return _buildPostCard(post);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Individual Post Card UI ---
  Widget _buildPostCard(Post post) {
    final TextEditingController commentController = TextEditingController();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Details
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Colors.deepOrange,
                child: Icon(Icons.verified_user, color: Colors.white, size: 20),
              ),
              title: Text(
                post.authorName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${post.authorLocation} • ${_formatTimestamp(post.timestamp)}'),
            ),

            // Content
            Text(
              post.content,
              style: const TextStyle(fontSize: 15, height: 1.3),
            ),
            const SizedBox(height: 12),

            // Action Buttons (Like / Comment Counter)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      post.likes++;
                    });
                    _dbHelper.updateLikes(post.id, post.likes);
                  },
                ),
                Text('${post.likes} likes', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 20),
                const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                const SizedBox(width: 6),
                Text('${post.comments.length} comments'),
              ],
            ),

            // Comments List
            if (post.comments.isNotEmpty) ...[
              const Divider(),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: post.comments
                      .map((comment) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      '💬 $comment',
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ))
                      .toList(),
                ),
              ),
            ],

            // Add Comment Input
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.reply, color: Colors.deepOrange, size: 20),
                    onPressed: () async {
                      if (commentController.text.trim().isNotEmpty) {
                        final comment = commentController.text.trim();
                        setState(() {
                          post.comments.add(comment);
                        });
                        await _dbHelper.insertComment(post.id, comment);
                        commentController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}