import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_blog/config/markdown_toc.dart';

class TocWidget extends StatefulWidget {
  final List<TocData> nodes;
  final bool useListView;
  final ScrollController markdownController;

  const TocWidget(
      {Key key, this.nodes = const [],this.useListView = false, this.markdownController})
      : super(key: key);

  @override
  _TocWidgetState createState() => _TocWidgetState();
}

class _TocWidgetState extends State<TocWidget> {
  int curIndex = 0;
  double lastOffset = 0.0;
  bool isDown = true;
  bool isTapingToc = false;

  @override
  void initState() {
    widget?.markdownController?.addListener(() {
      final controller = widget.markdownController;
      if(controller.hasClients && !isTapingToc){
        isDown = controller.offset >= lastOffset;
        lastOffset = controller.offset;
        final percent = controller.offset / controller.position.maxScrollExtent;
        int index = getCurrentIndex(widget.nodes, percent);
        index = widget.nodes[index].percent > percent ? (isDown ? index - 1 : index) : (isDown ? index: index + 1);
        if(index < 0) index = 0;
        if(index > widget.nodes.length - 1) index = widget.nodes.length - 1;
        if(curIndex != index){
          curIndex = index;
          _refresh();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return widget.useListView
        ? ListView.builder(
            itemBuilder: (ctx, index) =>
                getNodeWidget(widget.nodes[index], index, context),
            itemCount: widget.nodes.length,
          )
        : SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.nodes.length,
                  (index) => getNodeWidget(widget.nodes[index], index, context)),
            ),
          );
  }

  Widget getNodeWidget(TocData data, int index, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark ? true : false;
    final name = data.name;
    final level = data.level > 6 ? 6 : data.level;
    final percent = data.percent;
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(border: Border(left: BorderSide(color: curIndex == index ? Theme.of(context).textSelectionColor : Colors.grey))),
      child: InkWell(
        child: Container(
          margin: EdgeInsets.fromLTRB(4.0 + 10 * (level - 1),4,4,4),
          child: Text(
            name,
            style: curIndex == index
                ? TextStyle(color: Theme.of(context).textSelectionColor,fontSize: 12)
                : TextStyle(fontSize: 12, color: isDark ? Colors.grey : null),
          ),
        ),
        onTap: () {
          if (index != curIndex) {
            curIndex = index;
            isTapingToc = true;
            _refresh();
            widget.markdownController.animateTo(
                widget.markdownController.position.maxScrollExtent *
                    percent,
                duration: Duration(milliseconds: 300),
                curve: Curves.ease).then((value) => isTapingToc = false);
          }

        },
      ),
    );
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  int getCurrentIndex(List<TocData> nodes, double curPercent){
    var left = 0;
    var right = nodes.length - 1;
    while(left < right){
      final mid = (left + right) ~/ 2;
      final m = nodes[mid];
      if(m.percent > curPercent){
        right = mid;
      } else if(m.percent < curPercent){
        left = mid + 1;
      } else{
        return mid;
      }
    }
    return left;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
