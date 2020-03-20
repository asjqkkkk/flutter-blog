class TocData {
  double percent;
  String name;
  int level;

  TocData(this.percent, this.name, this.level);

  @override
  String toString() {
    return 'TocNode{percent: $percent, name: $name, deep: $level}';
  }
}

class TocNode{
  double percent;
  String name;
  int deep;
  List<TocNode> children;

  TocNode(this.percent, this.name, this.deep, this.children);

  @override
  String toString() {
    return 'TocNode{percent: $percent, name: $name, deep: $deep, children: $children}';
  }


}

enum FilterType { before, start, mid, end }

List<TocData> parseToList(String input) {
  FilterType type = FilterType.before;
  int deep = 0;
  double percent = 0.0;
  String name = '';
  final List<TocData> nodes = [];
  for (var i = 0; i < input.length; ++i) {
    var c = input[i];

    if (i == 0 && c == '#') {
      deep++;
      type = FilterType.start;
      continue;
    }

    switch (type) {
      case FilterType.before:
        if (c == '#' &&
            i > 0 &&
            (input[i - 1] == '\r' || input[i - 1] == '\n')) {
          percent = i / input.length;
          deep++;
          type = FilterType.start;
        }
        break;
      case FilterType.start:
        if (c == '#') {
          deep++;
        } else if (c == ' ') {
          type = FilterType.mid;
        } else {
          deep = 0;
          name = '';
          type = FilterType.before;
        }
        break;
      case FilterType.mid:
        if (c == ' ' || c == '\n' || c == '\r') {
          deep = 0;
          name = '';
          type = FilterType.before;
        } else {
          name += c;
          type = FilterType.end;
        }
        break;
      case FilterType.end:
        if ((c == '\n' || c == '\r' || i == input.length) && name.isNotEmpty) {
          nodes.add(TocData(percent, name, deep));
          deep = 0;
          name = '';
          type = FilterType.before;
        } else if ((c == '\n' || c == '\r') && name.isEmpty) {
          deep = 0;
          name = '';
          type = FilterType.before;
        } else {
          name += c;
        }
        break;
    }
  }
  return nodes;
}
