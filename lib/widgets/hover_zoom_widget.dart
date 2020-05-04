import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HoverZoomWidget extends StatefulWidget {
  final Widget child;
  final double scale;
  final Offset origin;

  const HoverZoomWidget(
      {Key key, this.scale = 1.2, @required this.child, this.origin})
      : super(key: key);

  @override
  _HoverZoomWidgetState createState() => _HoverZoomWidgetState();
}

class _HoverZoomWidgetState extends State<HoverZoomWidget> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      origin: widget.origin ?? Offset(0.0, 0.0),
      scale: isHovering ? widget.scale : 1.0,
      child: MouseRegion(
        child: widget.child,
        onHover: (PointerHoverEvent event) {
          if (!isHovering) {
            setState(() {
              isHovering = true;
            });
          }
        },
        onExit: (PointerExitEvent event) {
          if (isHovering) {
            setState(() {
              isHovering = false;
            });
          }
        },
      ),
    );
  }
}
