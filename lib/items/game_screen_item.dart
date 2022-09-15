import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/json/game_item_json.dart';
import 'package:new_web/util/all_utils.dart';
import 'package:new_web/widgets/all_widgets.dart';
import 'package:markdown_widget/scrollable_positioned_list/scrollable_positioned_list.dart';

class GameScreenItem extends StatefulWidget {
  @override
  _GameScreenItemState createState() => _GameScreenItemState();
}

class _GameScreenItemState extends State<GameScreenItem> {
  final _controller = RoundShowController();
  final _curIndex = ValueNotifier(0);
  final _isWaiting = ValueNotifier(false);
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: v400 * 2 + v240,
      margin:
          EdgeInsets.only(bottom: v64, top: v110, left: v76, right: v160 - v76),
      decoration: BoxDecoration(boxShadow: boxShadows),
      child: buildBody(),
    );
  }

  Widget buildBody() {
    return ValueListenableBuilder(
        valueListenable: GlobalData.instance.gameScreenData,
        builder: (context, dynamic value, _) {
          return Stack(
            children: [
              if (hasData)
                RoundShowWidget(
                  controller: _controller,
                  child: buildBackground(curBackground),
                )
              else
                const SizedBox(),
              if (hasData) buildGameScreens() else buildEmptyLayout(),
            ],
          );
        });
  }

  Widget buildBackground(String? asset) {
    return LayoutBuilder(builder: (context, constrains) {
      return Container(
        width: constrains.maxWidth,
        height: constrains.maxHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(v16),
          child: LoadingImage(
              image: buildResizeImage(ExactAssetImage(asset!),
                  h: constrains.maxHeight),
              fit: BoxFit.cover,
              loadingWidget: buildShimmer(
                constrains.maxWidth,
                constrains.maxHeight,
              )),
        ),
      );
    });
  }

  Widget buildGameScreens() {
    return Column(
      children: [
        ValueListenableBuilder(
            valueListenable: _isWaiting,
            builder: (context, dynamic value, _) {
              return Expanded(
                  child: value ? const SizedBox() : buildScreenItems());
            }),
        Container(
          height: v180,
          child: Row(
            children: [
              Container(
                width: v80,
                child: ValueListenableBuilder<Iterable<ItemPosition>>(
                  valueListenable: _itemPositionsListener.itemPositions,
                  builder: (ctx, value, _) {
                    if (value == null || value.isEmpty) return const SizedBox();
                    final first = value.first.index;
                    if (first == 0) return const SizedBox();
                    return Center(
                      child: CusInkWell(
                        child: SvgPicture.asset(
                          Svg.musicLast,
                          color: Colors.white,
                          width: v40,
                          height: v40,
                        ),
                        onTap: () {
                          _itemScrollController.scrollTo(
                              index: first - 1,
                              duration: const Duration(milliseconds: 300));
                        },
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Container(
                  child: ScrollablePositionedList.builder(
                    padding: EdgeInsets.fromLTRB(0, v40, 0, v40),
                    scrollDirection: Axis.horizontal,
                    itemCount: dataCount,
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    itemBuilder: (ctx, index) => buildGameItems(index),
                  ),
                ),
              ),
              Container(
                  width: v80,
                  child: ValueListenableBuilder<Iterable<ItemPosition>>(
                    valueListenable: _itemPositionsListener.itemPositions,
                    builder: (ctx, value, _) {
                      if (value == null || value.isEmpty)
                        return const SizedBox();
                      final first = value.first.index;
                      final list = value.toList();
                      list.sort((a, b) => a.index - b.index);
                      if (list.last.index == dataCount - 1)
                        return const SizedBox();
                      return Center(
                        child: CusInkWell(
                          child: SvgPicture.asset(
                            Svg.musicNext,
                            color: Colors.white,
                            width: v40,
                            height: v40,
                          ),
                          onTap: () {
                            _itemScrollController.scrollTo(
                                index: first + 1,
                                duration: const Duration(milliseconds: 300));
                          },
                        ),
                      );
                    },
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildGameItems(int index) {
    final cur = dataList[index]!;
    final isLast = index == dataCount - 1 && index > 0;
    // final isCurrent = curIndex == index;
    return CusInkWell(
      onTap: () => chooseIndex(index),
      child: HoverMoveWidget(
        offset: Offset(0, -v20),
        child: Container(
          width: v160,
          height: v100,
          margin: EdgeInsets.only(right: isLast ? 0 : v20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(v12),
            child: LoadingImage(
                image:
                    buildResizeImage(ExactAssetImage(cur.gameThumb!), h: v100),
                fit: BoxFit.cover,
                delayLoading: null,
                loadingWidget: Container(
                  width: v160,
                  height: v100,
                  margin: EdgeInsets.only(right: isLast ? 0 : v20),
                  decoration: BoxDecoration(
                    color: randomColor,
                    borderRadius: BorderRadius.circular(v12),
                  ),
                )),
          ),
        ),
      ),
    );
  }

  Widget buildScreenItems() {
    final curCount = curData!.children!.length;
    const crossCount = 5;
    return Container(
      child: AnimationLimiter(
        child: GridView.count(
          crossAxisCount: crossCount,
          mainAxisSpacing: v10,
          crossAxisSpacing: v10,
          childAspectRatio: 1.6,
          padding: EdgeInsets.fromLTRB(v80, v40, v80, 0),
          children: List.generate(
            curCount,
            (index) {
              final cur = curData!.children![index];
              final isFirst = index == 0;
              final isLastInFirstLine = index == 4;
              final isFirstInLastLine = index % 5 == 0 && index >= curCount - 5;
              final isLast = index == curCount - 1;
              final needBorder =
                  isFirst || isLast || isFirstInLastLine || isLastInFirstLine;
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 2,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: CusInkWell(
                      onTap: () => showImages(index),
                      borderRadius: BorderRadius.zero,
                      child: LayoutBuilder(builder: (context, constrains) {
                        final child = Container(
                            width: constrains.maxWidth,
                            height: constrains.maxHeight,
                            child: LoadingImage(
                              delayLoading: null,
                              image: buildResizeImage(
                                  ExactAssetImage(cur.thumbPicPath!),
                                  h: constrains.maxHeight),
                              fit: BoxFit.cover,
                              loadingWidget: Container(
                                  width: constrains.maxWidth,
                                  height: constrains.maxHeight,
                                  color: randomColor),
                            ));
                        return Hero(
                          tag: '$screenShotTag$index',
                          child: needBorder
                              ? ClipRRect(
                                  child: child,
                                  borderRadius: BorderRadius.only(
                                    topLeft: isFirst
                                        ? Radius.circular(v16)
                                        : Radius.zero,
                                    topRight: isLastInFirstLine
                                        ? Radius.circular(v16)
                                        : Radius.zero,
                                    bottomLeft: isFirstInLastLine
                                        ? Radius.circular(v16)
                                        : Radius.zero,
                                    bottomRight: isLast
                                        ? Radius.circular(v16)
                                        : Radius.zero,
                                  ),
                                )
                              : child,
                        );
                      }),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future chooseIndex(int index) async {
    if (isWaiting) return;
    if (curIndex == index) return;
    _isWaiting.value = true;
    await _controller
        .changeWidget(buildBackground(dataList[index]!.gameBackground));
    _curIndex.value = index;
    _isWaiting.value = false;
    // refresh();
  }

  void showImages(int index) {
    FullScreenDialog.getInstance()!.showDialog(
        context,
        ScreenShotsGallery(
          gameScreenData: curData,
          initialIndex: index,
        ));
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  List<GameScreenData?> get dataList =>
      GlobalData.instance.gameScreenData.value ?? [];

  int get dataCount => dataList.length;

  int get curIndex => _curIndex.value;

  bool get hasData => dataList != null && dataList.isNotEmpty;

  bool get isWaiting => _isWaiting.value;

  String? get curBackground =>
      curData?.gameBackground ?? (curData?.children ?? []).first.picPath;

  GameScreenData? get curData => hasData ? dataList[curIndex] : null;
}
