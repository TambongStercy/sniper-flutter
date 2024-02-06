import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoItem extends StatefulWidget {
  const VideoItem({
    super.key,
  });

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late ChewieController _chewieController;

  late VideoPlayerController _videoPlayerController;
  @override
  void initState() {
    super.initState();

 
    () async {
      try {
        _videoPlayerController =
            VideoPlayerController.asset('assets/videos/videoFr.mp4');


        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          // aspectRatio: _videoPlayerController.value.aspectRatio,
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
      } on Exception catch (e) {
        print(e);
      }
    }();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Chewie(
        controller: _chewieController,
      ),
    );
  }
}
