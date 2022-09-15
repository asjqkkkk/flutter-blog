import 'package:flutter/material.dart';

class AnimatedColorWidget extends StatefulWidget {
  const AnimatedColorWidget({
    Key? key,
    required this.colorData,
    required this.colorWidgetBuilder,
    this.colorController,
    this.duration,
  }) : super(key: key);

  final ColorData colorData;
  final ColorWidgetBuilder colorWidgetBuilder;
  final ColorController? colorController;
  final Duration? duration;

  @override
  _AnimatedColorWidgetState createState() => _AnimatedColorWidgetState();
}

class _AnimatedColorWidgetState extends State<AnimatedColorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ColorTween _beginTween;
  late ColorTween _endTween;
  late Animation<Color?> _beginAnimation;
  Animation<Color?>? _endAnimation;
  late ColorData beginColor;

  @override
  void initState() {
    super.initState();
    beginColor = widget.colorData;
    _controller = AnimationController(
        vsync: this,
        duration: widget.duration ?? const Duration(milliseconds: 500));
    _beginTween = ColorTween(begin: beginColor.begin, end: beginColor.end);
    _beginAnimation = _beginTween.animate(_controller);
    widget.colorController?._asyncCallback = changeColors;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final beginColor = _beginAnimation.value;
        final endColor = _endAnimation?.value;
        final hasEmpty = beginColor == null || endColor == null;
        return widget.colorWidgetBuilder.call(
                context,
                hasEmpty
                    ? widget.colorData
                    : ColorData(beginColor, endColor));
      },
    );
  }

  Future changeColors(ColorData colorData) async {
    _controller.reset();
    _beginTween = ColorTween(begin: beginColor.begin, end: colorData.begin);
    _beginAnimation = _beginTween.animate(_controller);
    _endTween = ColorTween(begin: beginColor.end, end: colorData.end);
    _endAnimation = _endTween.animate(_controller);
    beginColor = colorData;
    return _controller.forward();
  }
}

class ColorController {
  _AsyncCallback? _asyncCallback;

  void dispose() {
    _asyncCallback = null;
  }

  Future? changeColor(ColorData colorData) async {
    return _asyncCallback?.call(colorData);
  }
}

class ColorData {
  ColorData(this.begin, this.end);

  final Color? begin;
  final Color? end;

  @override
  String toString() {
    return 'ColorData{begin: $begin, end: $end}';
  }
}

typedef ColorWidgetBuilder = Widget Function(
    BuildContext context, ColorData colorData);

typedef _AsyncCallback = Future Function(ColorData colorData);
