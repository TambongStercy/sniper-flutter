import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:snipper_frontend/utils.dart';

class VideoItem extends StatefulWidget {
  final String? videoUrl;
  final String? thumbnailUrl;

  const VideoItem({super.key, this.videoUrl, this.thumbnailUrl});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;
  bool _isVideoInitialized = false;
  bool _isLoading = true; // Added loading state
  String? _errorMessage; // Added error message state
  bool isPlaying = false;
  bool showThumbnail = true;

  @override
  void initState() {
    super.initState();

    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      print("No valid video URL provided to VideoItem.");
      // Set error state directly if URL is invalid from the start
      _errorMessage = "No video URL provided.";
      _isLoading = false;
      // Initialize dummy controller to avoid later null checks
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse('http://dummy.com'));
    } else {
      final uri = Uri.tryParse(widget.videoUrl!);
      if (uri == null || !(uri.isScheme('HTTP') || uri.isScheme('HTTPS'))) {
        print("Invalid video URL provided: ${widget.videoUrl}");
        _errorMessage = "Invalid video URL format.";
        _isLoading = false;
        _videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse('http://dummy.com'));
      } else {
        _videoPlayerController = VideoPlayerController.networkUrl(
          uri,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        // Initialize immediately
        _initializeVideoPlayer();
      }
    }

    // Remove listener logic from here, handle state in initialize
    // _videoPlayerController.addListener(() { ... });

    // Remove WidgetsBinding.instance.addPostFrameCallback
    // WidgetsBinding.instance.addPostFrameCallback((_) { ... });
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoInitialize: true,
        autoPlay: false,
        looping: false,
        placeholder: Center(
            child: CircularProgressIndicator()), // Show loading in Chewie
        errorBuilder: (context, errorMessage) {
          // Use Chewie's error builder for playback errors
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Playback Error: $errorMessage",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      );

      setState(() {
        _isVideoInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      print("Error initializing video player: $e");
      if (mounted) {
        setState(() {
          // Display specific error message based on Exception type if possible
          _errorMessage = "Could not load video. \nError: ${e.toString()}";
          _isLoading = false;
          _isVideoInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    // Only dispose chewieController if it was initialized
    if (_isVideoInitialized && mounted) {
      _chewieController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double aspectRatio = 16 / 9; // Default aspect ratio
    if (_isVideoInitialized &&
        _videoPlayerController.value.isInitialized &&
        _videoPlayerController.value.aspectRatio > 0) {
      aspectRatio = _videoPlayerController.value.aspectRatio;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          color: Colors.black, // Background color
          child: _buildPlayerUI(),
        ),
      ),
    );
  }

  Widget _buildPlayerUI() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      return Center(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.error_outline, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ])),
      );
    } else if (_isVideoInitialized) {
      // Use Chewie player once initialized
      return Chewie(controller: _chewieController);
    } else {
      // Fallback: Should not happen if logic is correct, but good practice
      return Center(
        child: Text(
          "Video player could not be initialized.",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
  }
}
