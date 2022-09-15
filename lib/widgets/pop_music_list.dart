import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';

import 'music_widget.dart';

class PopMusicList extends StatefulWidget {
  const PopMusicList({
    Key? key,
    this.initialPosition = Offset.zero,
    required this.musicPlayer,
  }) : super(key: key);

  final Offset initialPosition;
  final MusicPlayer? musicPlayer;

  @override
  _PopMusicListState createState() => _PopMusicListState();
}

class _PopMusicListState extends State<PopMusicList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;
  bool _isPop = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.musicPlayer!;
    final list = player.curList?.audios ?? [];
    final loopMode = player.loopMode;
    final isSingleMode = loopMode == LoopMode.single;
    final w = v300;
    final h = v200;
    return GestureDetector(
      onTap: () => pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(
              left: widget.initialPosition.dx + v10,
              top: widget.initialPosition.dy - h - v10,
              child: AnimatedBuilder(
                animation: _animation,
                child: Container(
                  width: w,
                  height: h,
                  decoration: BoxDecoration(
                    color: color17.withOpacity(0.5),
                    borderRadius: BorderRadius.all(Radius.circular(v18)),
                  ),
                  child: ListViewWithHeader(
                    header: Container(
                      height: v40,
                      child: InkWell(
                        onTap: () {
                          player
                              .setLoopMode(
                                isSingleMode
                                    ? LoopMode.playlist
                                    : LoopMode.single,
                              )
                              .then((value) => refresh());
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: v15,
                            ),
                            SvgPicture.asset(
                              isSingleMode
                                  ? Svg.musicCycleOne
                                  : Svg.musicCycleList,
                              width: v16,
                            ),
                            SizedBox(
                              width: v8,
                            ),
                            Text(
                              isSingleMode
                                  ? 'Repeat single song'
                                  : 'Loop music list',
                              style: CTextStyle(
                                fontSize: v12,
                                height: 1,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    itemBuilder: (ctx, index) {
                      final cur = list[index].metas;
                      final isCurPlaying = player.curIndex == index;
                      final color = isCurPlaying ? color18 : Colors.white;
                      final title = cur.title!;
                      final author = cur.artist!;
                      return InkWell(
                        onTap: () {
                          player.chooseSong(index).then((value) => refresh());
                        },
                        child: Container(
                          height: v32,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: v15,
                              ),
                              Flexible(
                                child: Text(
                                  title,
                                  overflow: TextOverflow.ellipsis,
                                  style: CTextStyle(
                                    fontSize: v12,
                                    height: 1,
                                    color: color,
                                  ),
                                ),
                              ),
                              Container(
                                width: v5,
                                height: v1,
                                margin: EdgeInsets.only(left: v5, right: v5),
                                decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(0.5)),
                              ),
                              Expanded(
                                child: Text(
                                  author,
                                  overflow: TextOverflow.ellipsis,
                                  style: CTextStyle(
                                    fontSize: v8,
                                    height: 1,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: list.length,
                  ),
                ),
                builder: (ctx, child) {
                  return Transform.scale(
                    scale: _animation.value,
                    child: child,
                    alignment: Alignment.bottomLeft,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void pop() {
    if (_isPop) return;
    _isPop = true;
    _controller.reverse().then((value) => Navigator.of(context).pop());
  }
}

class ListViewWithHeader extends StatelessWidget {
  const ListViewWithHeader(
      {Key? key,
      this.header,
      required this.itemBuilder,
      required this.itemCount})
      : super(key: key);

  final Widget? header;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (ctx, index) {
        final i = index - 1;
        if (index == 0) return header ?? const SizedBox();
        return itemBuilder.call(ctx, i);
      },
      itemCount: itemCount + 1,
    );
  }
}
