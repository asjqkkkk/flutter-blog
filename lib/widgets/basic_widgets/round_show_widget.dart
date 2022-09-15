import 'package:flutter/material.dart';

class RoundShowWidget extends StatefulWidget {
  const RoundShowWidget({
    Key? key,
    this.duration,
    this.curve = Curves.linear,
    this.controller,
    required this.child,
  }) : super(key: key);

  final Duration? duration;
  final Widget child;
  final Curve curve;
  final RoundShowController? controller;

  @override
  _RoundShowWidgetState createState() => _RoundShowWidgetState();
}

class _RoundShowWidgetState extends State<RoundShowWidget>
    with SingleTickerProviderStateMixin {
  Widget? _firstChild;
  Widget? _secondChild;
  late Animation<double> _animation;
  late AnimationController _controller;
  bool _isWorking = false;

  @override
  void initState() {
    _firstChild = widget.child;
    _secondChild = const SizedBox();
    _controller = AnimationController(
        vsync: this,
        duration: widget.duration ?? const Duration(milliseconds: 500));
    _animation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    widget.controller?._asyncCallback = changeWidget;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _firstChild!,
        AnimatedBuilder(
            animation: _animation,
            builder: (ctx, child) {
              final value = _animation.value;
              return ClipOval(
                clipper: MyClipper(percent: value),
                child: _secondChild,
              );
            }),
      ],
    );
  }

  Future changeWidget(Widget newWidget) async {
    if (_isWorking) return;
    if (_secondChild == newWidget) return;
    _isWorking = true;
    _controller.reset();
    _secondChild = newWidget;
    refresh();
    await _controller.forward();
    _firstChild = _secondChild;
    _isWorking = false;
    refresh();
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}

class RoundShowController {
  _AsyncCallback? _asyncCallback;

  void dispose() {
    _asyncCallback = null;
  }

  Future? changeWidget(Widget newWidget) async {
    return _asyncCallback?.call(newWidget);
  }
}

typedef _AsyncCallback = Future Function(Widget newWidget);

class MyClipper extends CustomClipper<Rect> {
  MyClipper({this.percent = 0.0});

  final double percent;

  @override
  Rect getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final radius = percent * Offset(w, h).distance / 2;
    return Rect.fromCircle(
      center: Offset(w / 2, h / 2),
      radius: radius,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}
