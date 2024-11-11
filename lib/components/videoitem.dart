import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoItem extends StatefulWidget {
  const VideoItem({super.key});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;
  bool _isVideoInitialized = false; // Track initialization status

  @override
  void initState() {
    super.initState();

    // Delay the context-dependent code until after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideoPlayer();
    });
  }

  Future<void> _initializeVideoPlayer() async {
    print(Localizations.localeOf(context).languageCode);
    try {
      _videoPlayerController = VideoPlayerController.asset(
        'assets/videos/video${Localizations.localeOf(context).languageCode == 'en' ? 'En' : 'Fr'}.mp4',
      );

      await _videoPlayerController
          .initialize(); // Ensure the controller is initialized

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoInitialize: true,
        autoPlay: false,
        looping: false,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {
        _isVideoInitialized = true; // Set initialization flag to true
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if the video is initialized before rendering the video widget
    if (!_isVideoInitialized) {
      return Center(
        child:
            CircularProgressIndicator(), // Show a loading indicator while initializing
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: _videoPlayerController.value.aspectRatio,
        child: Chewie(
          controller: _chewieController,
        ),
      ),
    );
  }
}
