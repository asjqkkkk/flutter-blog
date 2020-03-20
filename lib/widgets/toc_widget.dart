import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_blog/config/markdown_toc.dart';

class TocWidget extends StatefulWidget {
  final List<TocData> nodes;
  final Function(double percent) onTap;
  final bool useListView;
  final ScrollController markdownController;

  const TocWidget(
      {Key key, this.nodes = const [], this.onTap, this.useListView = false, this.markdownController})
      : super(key: key);

  @override
  _TocWidgetState createState() => _TocWidgetState();
}

class _TocWidgetState extends State<TocWidget> {
  int curIndex = 0;
  double lastOffset = 0.0;
  bool isDown = true;

  @override
  void initState() {
    widget?.markdownController?.addListener(() {
      final controller = widget.markdownController;
      if(controller.hasClients){
        isDown = controller.offset >= lastOffset;
        lastOffset = controller.offset;
        final percent = controller.offset / controller.position.maxScrollExtent;
        int index = getCurrentIndex(widget.nodes, percent);
        index = widget.nodes[index].percent > percent ? (isDown ? index - 1 : index) : (isDown ? index + 1 : index);
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
                getNodeWidget(widget.nodes[index], index),
            itemCount: widget.nodes.length,
          )
        : SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.nodes.length,
                  (index) => getNodeWidget(widget.nodes[index], index)),
            ),
          );
  }

  Widget getNodeWidget(TocData data, int index) {
    final name = data.name;
    final level = data.level > 6 ? 6 : data.level;
    final percent = data.percent;
    return Container(
      alignment: Alignment.centerLeft,
      child: InkWell(
        child: Container(
          margin: EdgeInsets.all(4),
          child: Text(
            '  ' * (level - 1) + name,
            style: curIndex == index
                ? TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textSelectionColor)
                : TextStyle(),
          ),
        ),
        onTap: () {
          if (widget.onTap != null) widget.onTap(percent);
          if (index != curIndex) {
            curIndex = index;
            _refresh();
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
