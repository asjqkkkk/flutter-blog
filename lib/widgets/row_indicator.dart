import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';

class RowIndicator extends StatefulWidget {
  const RowIndicator({
    Key? key,
    this.children,
    this.duration,
    this.curve = Curves.easeInOut,
    this.indicator,
    this.indicatorController,
    this.limitSize = 40,
    this.initialIndex = 0,
  }) : super(key: key);

  final List<Widget>? children;
  final Duration? duration;
  final Curve curve;
  final Widget? indicator;
  final int initialIndex;
  final double limitSize;
  final IndicatorController? indicatorController;

  @override
  _RowIndicatorState createState() => _RowIndicatorState();
}

class _RowIndicatorState extends State<RowIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;
  int? _current;
  int? _newIndex;
  bool _isDoingAnimation = false;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 500),
    );
    _animation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    widget.indicatorController?._asyncCallback = changeIndex;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.children!;
    final indicator = widget.indicator ??
        Center(
          child: Container(
            width: v12,
            height: v12,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(children.length, (index) {
        final cur = children[index];
        final isCur = _current == index;
        final isNewIndex = index == _newIndex;
        final isNormal = !isCur && !isNewIndex;
        final isFirst = index == 0;
        return Container(
          width: widget.limitSize,
          height: widget.limitSize,
          margin: EdgeInsets.only(left: isFirst ? 0 : v16),
          child: isNormal
              ? cur
              : Stack(
                  children: [
                    cur,
                    if (isCur || isNewIndex)
                      Center(
                        child: AnimatedBuilder(
                            animation: _animation,
                            builder: (ctx, child) {
                              final curScale = 1 - _animation.value;
                              final indexScale = _animation.value;
                              return isCur
                                  ? Transform.scale(
                                      scale: curScale as double,
                                      child: indicator,
                                    )
                                  : Transform.scale(
                                      scale: indexScale,
                                      child: indicator,
                                    );
                            }),
                      )
                  ],
                ),
        );
      }),
    );
  }

  Future changeIndex(int index) async {
    if (index == _current) return;
    if (!_isDoingAnimation) {
      _isDoingAnimation = true;
    } else {
      _controller.reverse();
      _newIndex = null;
      _current = index;
      _isDoingAnimation = false;
      return;
    }
    _newIndex = index;
    refresh();
    await _controller.forward();
    _current = index;
    _newIndex = null;
    _controller.reset();
    refresh();
    _isDoingAnimation = false;
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}

class IndicatorController {
  _AsyncCallback? _asyncCallback;

  void dispose() {
    _asyncCallback = null;
  }

  Future? changeIndex(int index) async {
    return _asyncCallback?.call(index);
  }
}

typedef _AsyncCallback = Future Function(int index);
