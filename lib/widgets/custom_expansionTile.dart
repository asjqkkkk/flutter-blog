import 'package:flutter/material.dart';

class CustomExpansionTile extends StatefulWidget {
  const CustomExpansionTile({
    Key? key,
    this.tilePadding,
    this.childrenPadding,
    required this.title,
    this.onExpansionChanged,
    this.trailing,
    this.initiallyExpanded = false,
    this.children = const <Widget>[],
  }) : super(key: key);

  final EdgeInsetsGeometry? tilePadding;
  final EdgeInsetsGeometry? childrenPadding;
  final Widget title;
  final ValueChanged<bool>? onExpansionChanged;
  final WidgetValueChanged<bool>? trailing;
  final bool initiallyExpanded;
  final List<Widget> children;

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool expanded = false;

  @override
  void initState() {
    super.initState();
    expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: widget.title,
      tilePadding: widget.tilePadding,
      childrenPadding: widget.childrenPadding,
      onExpansionChanged: (value) {
        expanded = value;
        widget.onExpansionChanged?.call(value);
        setState(() {});
      },
      trailing: widget.trailing?.call(expanded),
      initiallyExpanded: widget.initiallyExpanded,
      children: widget.children,
    );
  }
}

typedef WidgetValueChanged<T> = Widget Function(T value);
