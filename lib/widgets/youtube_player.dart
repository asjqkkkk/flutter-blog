import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePlayer extends StatefulWidget {
  const YoutubePlayer({Key? key, required this.youtubeId}) : super(key: key);
  final String? youtubeId;

  @override
  _YoutubePlayerState createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  YoutubePlayerController? _controller;
  bool isReady = false;

  @override
  void initState() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeId!,
      params: const YoutubePlayerParams(
          showControls: true, showFullscreenButton: true, autoPlay: false),
    );
//    _controller.listen((event) {
//      print('准备好了吗:${event.isReady}');
//    });

    super.initState();
  }

  @override
  void dispose() {
    _controller!.close();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: YoutubePlayerIFrame(
        controller: _controller,
        aspectRatio: 16 / 9,
      ),
    );
  }
}
