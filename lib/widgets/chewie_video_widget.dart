import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CheWieVideoWidget extends StatefulWidget {
  final String url;

  const CheWieVideoWidget({Key key, @required this.url}) : super(key: key);

  @override
  _CheWieVideoWidgetState createState() => _CheWieVideoWidgetState();
}

class _CheWieVideoWidgetState extends State<CheWieVideoWidget> {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.network(widget.url);
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: 3 / 2,
        autoPlay: false,
        autoInitialize: true,
        looping: false,
        allowMuting: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: _chewieController,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
