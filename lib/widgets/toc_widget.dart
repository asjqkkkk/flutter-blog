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
  bool isTapingToc = false;
  bool isScrolling = false;

  @override
  void initState() {
    widget?.markdownController?.addListener(() {
      final controller = widget.markdownController;
      if(controller.hasClients && !isTapingToc && !isScrolling){
        if(controller.offset == lastOffset) return;
        isScrolling = true;
        
        bool isDown = controller.offset > lastOffset;
        lastOffset = controller.offset;
        final percent = controller.offset / controller.position.maxScrollExtent;
        if(curIndex > widget.nodes.length - 1) curIndex = 0;
        int index = getCurrentIndex(widget.nodes, percent, curIndex, isDown);
        if(index < 0) index = 0;
        if(index > widget.nodes.length - 1) index = widget.nodes.length - 1;
        isScrolling = false;
        if(curIndex != index){
          if((isDown && index >= curIndex) ||(!isDown && index <= curIndex)){
            curIndex = index;
            _refresh();
          }
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
      padding: EdgeInsets.only(left: 10),
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

  int getCurrentIndex(List<TocData> nodes, double curPercent, int lastIndex, bool isDown){
    double min = double.maxFinite;
    int result = 0;
    if(isDown){
      for (var i = lastIndex; i < nodes.length; ++i) {
        var curNode = nodes[i];
        final abs = (curNode.percent - curPercent).abs();
        if(min > abs) {
          min = abs;
          result = i;
        } else if(min < abs && min != double.maxFinite) break;
      }
    } else {
      for (var i = lastIndex; i >= 0; i--) {
        var curNode = nodes[i];
        final abs = (curNode.percent - curPercent).abs();
        if(min > abs) {
          min = abs;
          result = i;
        } else if(min < abs && min != double.maxFinite) break;
      }
    }
//    var left = 0;
//    var right = nodes.length - 1;
//    while(left < right){
//      final mid = (left + right) ~/ 2;
//      final m = nodes[mid];
//      if(m.percent > curPercent){
//        right = mid;
//      } else if(m.percent < curPercent){
//        left = mid + 1;
//      } else{
//        return mid;
//      }
//    }
    return result;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
