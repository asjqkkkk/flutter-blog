//class TocData {
//  double percent;
//  String name;
//  int level;
//
//  TocData(this.percent, this.name, this.level);
//
//  @override
//  String toString() {
//    return 'TocNode{percent: $percent, name: $name, deep: $level}';
//  }
//
//}
//
//class TocNode{
//  double percent;
//  String name;
//  int deep;
//  List<TocNode> children;
//
//  TocNode(this.percent, this.name, this.deep, this.children);
//
//  @override
//  String toString() {
//    return 'TocNode{percent: $percent, name: $name, deep: $deep';
//  }
//
//  static TocNode fromData(TocData other){
//    return TocNode(other.percent, other.name, other.level, null);
//  }
//}
//
//enum FilterType { before, start, mid, end }
//
//List<TocData> parseToDataList(String input) {
//  FilterType type = FilterType.before;
//  int deep = 0;
//  String name = '';
//  final List<TocData> dataList = [];
//  for (var i = 0; i < input.length; ++i) {
//    var c = input[i];
//
//    if (i == 0 && c == '#') {
//      deep++;
//      type = FilterType.start;
//      continue;
//    }
//
//    switch (type) {
//      case FilterType.before:
//        if (c == '#' &&
//            i > 0 &&
//            (input[i - 1] == '\r' || input[i - 1] == '\n')) {
//          deep++;
//          type = FilterType.start;
//        }
//        break;
//      case FilterType.start:
//        if (c == '#') {
//          deep++;
//        } else if (c == ' ') {
//          type = FilterType.mid;
//        } else {
//          deep = 0;
//          name = '';
//          type = FilterType.before;
//        }
//        break;
//      case FilterType.mid:
//        if (c == ' ' || c == '\n' || c == '\r') {
//          deep = 0;
//          name = '';
//          type = FilterType.before;
//        } else {
//          name += c;
//          type = FilterType.end;
//        }
//        break;
//      case FilterType.end:
//        if ((c == '\n' || c == '\r' || i == input.length - 1) && name.isNotEmpty) {
//          final percent = i / input.length;
//          dataList.add(TocData(percent, name, deep));
//          deep = 0;
//          name = '';
//          type = FilterType.before;
//        } else if ((c == '\n' || c == '\r') && name.isEmpty) {
//          deep = 0;
//          name = '';
//          type = FilterType.before;
//        } else {
//          name += c;
//        }
//        break;
//    }
//  }
//  return dataList;
//}
//
//List<TocNode> parseToNodeList(String input){
//  List<TocData> dataList = parseToDataList(input);
//  final root = TocNode(0.0, 'root', 0, null,);
//  _parseToNodeList(root, dataList, 0);
//  return root.children;
//}
//
//void printChild(List<TocNode> children){
//  if(children == null) return;
//  for (var node in children) {
//    print('${node.toString()} \n');
//    printChild(node.children);
//  }
//}
//
//void _parseToNodeList(TocNode parent, List<TocData> dataList, int index){
//  if(index > dataList.length - 1) return;
//  for (var i = index; i < dataList.length; ++i) {
//    if(dataList[i] == null) continue;
//    final curNode= TocNode.fromData(dataList[i]);
//    if(curNode.deep > parent.deep){
//      if(parent.children == null) {
//        parent.children = [];
//      }
//      parent.children.add(curNode);
//      dataList[i] = null;
//      _parseToNodeList(curNode, dataList, i + 1);
//    } else {
//      return;
//    }
//  }
//}
