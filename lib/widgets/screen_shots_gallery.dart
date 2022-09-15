import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/json/game_item_json.dart';

import 'all_widgets.dart';

class ScreenShotsGallery extends StatefulWidget {
  const ScreenShotsGallery({
    Key? key,
    required this.gameScreenData,
    this.initialIndex,
  }) : super(key: key);

  final GameScreenData? gameScreenData;
  final int? initialIndex;

  @override
  _ScreenShotsGalleryState createState() => _ScreenShotsGalleryState();
}

class _ScreenShotsGalleryState extends State<ScreenShotsGallery> {
  PageController? _controller;
  final _curIndex = ValueNotifier(0);

  @override
  void initState() {
    _curIndex.value = widget.initialIndex ?? 0;
    _controller = PageController(initialPage: curIndex);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.2),
        body: Container(
          margin: EdgeInsets.fromLTRB(v60, v100, v60, v100),
          child: Row(
            children: [
              Container(
                width: v100,
                height: v100,
                padding: EdgeInsets.only(right: v20),
                child: ValueListenableBuilder(
                    valueListenable: _curIndex,
                    builder: (context, dynamic value, _) {
                      if (value == 0) return const SizedBox();
                      return IconButton(
                        icon: SvgPicture.asset(
                          Svg.musicLast,
                          color: Colors.white,
                          width: v40,
                          height: v40,
                        ),
                        padding: EdgeInsets.only(right: v10),
                        iconSize: v80,
                        onPressed: previousPage,
                      );
                    }),
              ),
              Expanded(
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _controller,
                  itemCount: childCount,
                  itemBuilder: (ctx, index) {
                    final item = items[index];
                    return LayoutBuilder(builder: (context, constrains) {
                      final child = Container(
                        width: constrains.maxWidth,
                        height: constrains.maxHeight,
                        child: LoadingImage(
                            image: ExactAssetImage(item.picPath!),
                            delayLoading: null,
                            fit: BoxFit.contain,
                            loadingWidget: SizedBox(
                              width: constrains.maxWidth,
                              height: constrains.maxHeight,
                              child: Stack(
                                children: [
                                  Container(
                                    width: constrains.maxWidth,
                                    height: constrains.maxHeight,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                      image: ExactAssetImage(item.thumbPicPath!),
                                      fit: BoxFit.contain,
                                    )),
                                    child: buildEmptyLayout(),
                                  ),
                                ],
                              ),
                            )),
                      );
                      return Hero(
                        tag: '$screenShotTag$index',
                        child: child,
                      );
                    });
                  },
                  onPageChanged: (page) {
                    _curIndex.value = page;
                  },
                ),
              ),
              Container(
                width: v100,
                height: v100,
                padding: EdgeInsets.only(left: v20),
                child: ValueListenableBuilder(
                    valueListenable: _curIndex,
                    builder: (context, dynamic value, _) {
                      if (value == childCount - 1) return const SizedBox();
                      return IconButton(
                        icon: SvgPicture.asset(
                          Svg.musicNext,
                          color: Colors.white,
                          width: v40,
                          height: v40,
                        ),
                        padding: EdgeInsets.only(left: v10),
                        iconSize: v80,
                        onPressed: nextPage,
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void nextPage() {
    if (isLast) return;
    _controller!.animateToPage(curIndex + 1,
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  void previousPage() {
    if (isFirst) return;
    _controller!.animateToPage(curIndex - 1,
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  int get childCount => items.length;

  int get curIndex => _curIndex.value;

  bool get isFirst => curIndex == 0;

  bool get isLast => curIndex == childCount - 1;

  List<ChildItem> get items => widget.gameScreenData?.children ?? [];
}

const String screenShotTag = 'screenShotTag';
