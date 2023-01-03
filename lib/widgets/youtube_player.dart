import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/widget_visitor.dart';
import 'package:markdown_widget/widget/span_node.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MyYoutubePlayer extends StatefulWidget {
  const MyYoutubePlayer({Key? key, required this.youtubeId}) : super(key: key);
  final String youtubeId;

  @override
  _MyYoutubePlayerState createState() => _MyYoutubePlayerState();
}

class _MyYoutubePlayerState extends State<MyYoutubePlayer> {
  late YoutubePlayerController _controller;
  bool isReady = false;

  @override
  void initState() {
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.youtubeId,
      autoPlay: false,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
//    _controller.listen((event) {
//      print('准备好了吗:${event.isReady}');
//    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: YoutubePlayer(
        controller: _controller,
        aspectRatio: 16 / 9,
      ),
    );
  }
}

class YoutubeNode extends SpanNode {
  YoutubeNode(this.params);

  final Map<String, String> params;

  @override
  InlineSpan build() {
    final youtubeId = params['id'] ?? '';

    return WidgetSpan(child: MyYoutubePlayer(youtubeId: youtubeId));
  }
}

SpanNodeGeneratorWithTag youtubeGenerator = SpanNodeGeneratorWithTag(
    tag: 'youtube',
    generator: (e, config, visitor) => YoutubeNode(e.attributes));
