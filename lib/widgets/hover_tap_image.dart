import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HoverTapImage extends StatefulWidget {
  final String image;
  final double size;
  final Color onHoverColor;

  const HoverTapImage(
      {Key key,
      @required this.image,
      this.size = 30.0,
      this.onHoverColor = Colors.lightBlueAccent})
      : super(key: key);

  @override
  _HoverTapImageState createState() => _HoverTapImageState();
}

class _HoverTapImageState extends State<HoverTapImage> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: Stack(
        children: <Widget>[
          Image.asset(
            widget.image,
            width: widget.size,
            height: widget.size,
          ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHovering ? widget.onHoverColor.withOpacity(0.3) : null,
            ),
          )
        ],
      ),
      onHover: (PointerHoverEvent event) {
        print("isHovering");
        if (!isHovering) {
          setState(() {
            isHovering = true;
          });
        }
      },
      onExit: (PointerExitEvent event) {
        print("hoveringOnExit");
        if (isHovering) {
          setState(() {
            isHovering = false;
          });
        }
      },
    );
  }
}
