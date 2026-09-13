import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'social_feed_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SocialFeedTab(),
    const AudioTracksTab(),
    const VideoStreamTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odi Wa Turkana'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.audiotrack),
            label: 'Audio Tracks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Videos',
          ),
        ],
      ),
    );
  }
}

// --- Audio Tracks Tab (Supports Remote URLs and Local Storage Files) ---
class AudioTracksTab extends StatefulWidget {
  const AudioTracksTab({super.key});

  @override
  State<AudioTracksTab> createState() => _AudioTracksTabState();
}

class _AudioTracksTabState extends State<AudioTracksTab> {
  VideoPlayerController? _audioController;
  String? _currentlyPlayingTitle;
  bool _isPlaying = false;

  final List<Map<String, String>> audioTracks = [
    {
      'title': 'Kakuma Anthem',
      'album': 'Turkana Rise Vol. 1',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      'imageUrl': 'https://picsum.photos/id/1082/200/200',
    },
    {
      'title': 'Odi Unplugged (Live in Lodwar)',
      'album': 'Live Sessions',
      'url': 'https://cdn.pixabay.com/download/audio/2022/01/18/audio_d0a13f69d2.mp3',
      'imageUrl': 'https://picsum.photos/id/1084/200/200',
    },
  ];

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.audio.request();
      await Permission.storage.request();
    }
  }

  Future<void> _pickLocalAudioFile() async {
    await _requestPermissions();

    final file = await FilePicker.pickFile(
      type: FileType.audio,
    );

    if (file != null && file.path != null) {
      String localPath = file.path!;
      String fileName = file.name;

      setState(() {
        audioTracks.add({
          'title': fileName,
          'album': 'Local Device Track',
          'url': localPath,
          'imageUrl': '',
        });
      });

      _playAudio(fileName, localPath);
    }
  }

  Future<void> _playAudio(String title, String pathOrUrl) async {
    try {
      if (_audioController != null) {
        await _audioController!.dispose();
      }

      if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
        _audioController = VideoPlayerController.networkUrl(Uri.parse(pathOrUrl));
      } else {
        _audioController = VideoPlayerController.file(File(pathOrUrl));
      }

      await _audioController!.initialize();

      setState(() {
        _currentlyPlayingTitle = title;
        _isPlaying = true;
      });

      _audioController!.play();
    } catch (e) {
      debugPrint("Audio Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to play file: $title')),
        );
      }
    }
  }

  void _togglePlayPause() {
    if (_audioController != null) {
      setState(() {
        if (_audioController!.value.isPlaying) {
          _audioController!.pause();
          _isPlaying = false;
        } else {
          _audioController!.play();
          _isPlaying = true;
        }
      });
    }
  }

  @override
  void dispose() {
    _audioController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            onPressed: _pickLocalAudioFile,
            icon: const Icon(Icons.folder_open),
            label: const Text('Browse Device Storage for MP3'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: audioTracks.length,
            itemBuilder: (context, index) {
              final track = audioTracks[index];
              final isThisTrackPlaying = _currentlyPlayingTitle == track['title'] && _isPlaying;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: track['imageUrl'] != null && track['imageUrl']!.isNotEmpty
                        ? Image.network(
                      track['imageUrl']!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.music_note, color: Colors.deepOrange),
                    )
                        : const Icon(Icons.sd_storage, color: Colors.deepOrange, size: 40),
                  ),
                  title: Text(
                    track['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Odi Wa Turkana • ${track['album']}'),
                  trailing: IconButton(
                    icon: Icon(
                      isThisTrackPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: Colors.deepOrange,
                      size: 38,
                    ),
                    onPressed: () {
                      if (_currentlyPlayingTitle == track['title']) {
                        _togglePlayPause();
                      } else {
                        _playAudio(track['title']!, track['url']!);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom Player Bar
        if (_currentlyPlayingTitle != null)
          Container(
            color: Colors.deepOrange.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('NOW PLAYING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(
                        _currentlyPlayingTitle!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlayPause,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// --- Video Component (Supports Remote and Local Video Files) ---
class InAppVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;

  const InAppVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<InAppVideoPlayer> createState() => _InAppVideoPlayerState();
}

class _InAppVideoPlayerState extends State<InAppVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.videoUrl.startsWith('http://') || widget.videoUrl.startsWith('https://')) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      } else {
        _videoController = VideoPlayerController.file(File(widget.videoUrl));
      }

      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
      );
      setState(() {});
    } catch (e) {
      debugPrint("Video Error: $e");
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            color: Colors.black,
            child: _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Video Streaming Tab ---
class VideoStreamTab extends StatefulWidget {
  const VideoStreamTab({super.key});

  @override
  State<VideoStreamTab> createState() => _VideoStreamTabState();
}

class _VideoStreamTabState extends State<VideoStreamTab> {
  final List<Map<String, String>> videos = [
    {
      'title': 'Live Concert: Kakuma Cultural Festival',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    },
    {
      'title': 'Music Video: Kakuma Anthem (Official)',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    },
  ];

  Future<void> _pickLocalVideoFile() async {
    if (Platform.isAndroid) {
      await Permission.videos.request();
      await Permission.storage.request();
    }

    final file = await FilePicker.pickFile(
      type: FileType.video,
    );

    if (file != null && file.path != null) {
      setState(() {
        videos.add({
          'title': file.name,
          'url': file.path!,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            onPressed: _pickLocalVideoFile,
            icon: const Icon(Icons.video_file),
            label: const Text('Browse Device Storage for MP4'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return InAppVideoPlayer(
                key: ValueKey(videos[index]['url']),
                title: videos[index]['title']!,
                videoUrl: videos[index]['url']!,
              );
            },
          ),
        ),
      ],
    );
  }
}