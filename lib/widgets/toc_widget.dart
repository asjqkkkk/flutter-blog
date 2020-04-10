import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter_blog/config/platform_type.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class TocWidget extends StatefulWidget {
  final LinkedHashMap<int, Toc> tocList;
  final TocController controller;

  const TocWidget({Key key, this.tocList, this.controller}) : super(key: key);

  @override
  _TocWidgetState createState() => _TocWidgetState();
}

class _TocWidgetState extends State<TocWidget> {
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ItemScrollController itemScrollController = ItemScrollController();
  Toc currentToc;

  @override
  void initState() {
    bool isMobile = PlatformType().isMobile();
    widget?.controller?.addListener(() {
      final toc = widget.controller.toc;
      if (toc == null) return;
      if (currentToc == toc) return;
      currentToc = toc;
      if (itemScrollController.isAttached && !isMobile)
        itemScrollController.scrollTo(
            index: currentToc.selfIndex, duration: Duration(milliseconds: 1));
      refresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.tocList;
    final keys = list?.keys?.toList();
    return list == null
        ? Center(child: CircularProgressIndicator())
        : buildToc(keys, list);
  }

  Widget buildToc(List<int> keys, LinkedHashMap<int, Toc> list) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overScroll) {
        overScroll.disallowGlow();
        return true;
      },
      child: ScrollablePositionedList.builder(
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final tocIndex = keys[index];
          final toc = list[tocIndex];
          return getNodeWidget(toc, tocIndex, context);
        },
        initialScrollIndex: widget?.controller?.toc?.selfIndex ?? 0,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
      ),
    );
  }

  Widget getNodeWidget(Toc toc, int tocIndex, BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    final name = toc.name;
    final level = toc.tagLevel;
    bool isCurrent = currentToc == toc;
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          border: Border(
              left: BorderSide(
                  color: isCurrent
                      ? Theme.of(context).textSelectionColor
                      : Colors.grey))),
      padding: EdgeInsets.only(left: 10),
      child: InkWell(
        child: Container(
          margin: EdgeInsets.fromLTRB(4.0 + 10 * level, 4, 4, 4),
          child: Text(
            name,
            style: isCurrent
                ? TextStyle(
                    color: Theme.of(context).textSelectionColor, fontSize: 12)
                : TextStyle(fontSize: 12, color: isDark ? Colors.grey : null),
          ),
        ),
        onTap: () {
          if (!isCurrent) {
            final controller = widget?.controller?.scrollController;
            if (controller?.isAttached ?? false)
              controller?.jumpTo(index: tocIndex);
          }
        },
      ),
    );
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}
