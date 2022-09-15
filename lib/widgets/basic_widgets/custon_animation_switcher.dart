import 'package:flutter/material.dart';

class CustomAnimatedSwitcher extends StatefulWidget {
  const CustomAnimatedSwitcher({
    Key? key,
    this.duration,
    this.childBuilder,
    this.child,
    this.switcherController,
    this.enableScale = true,
    this.enableFade = true,
  })  : assert(childBuilder != null || child != null),
        super(key: key);

  final Duration? duration;
  final Widget? child;
  final SwitcherController? switcherController;
  final _WidgetBuilder? childBuilder;
  final bool enableScale;
  final bool enableFade;

  @override
  _CustomAnimatedSwitcherState createState() => _CustomAnimatedSwitcherState();
}

class _CustomAnimatedSwitcherState extends State<CustomAnimatedSwitcher> {
  int _value = 0;

  _WidgetBuilder? _newWidget;

  @override
  void initState() {
    widget.switcherController?._asyncCallback = changeWidget;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.duration ?? const Duration(milliseconds: 300),
      child: Container(
          key: ValueKey(_value),
          child: _newWidget?.call() ??
              widget.child ??
              widget.childBuilder?.call()),
      transitionBuilder: (child, animation) {
        final enableScale = widget.enableScale;
        final enableFade = widget.enableFade;
        Widget c = child;
        if(enableScale) c = ScaleTransition(
          scale: animation,
          child: c,
        );
        if(enableFade) c = FadeTransition(
            opacity: animation,
          child: c,
        );
        return c;
      },
    );
  }

  Future changeWidget(_WidgetBuilder newWidget) async {
    _value++;
    _newWidget = newWidget;
    refresh();
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}

class SwitcherController {
  _AsyncCallback? _asyncCallback;

  void dispose() {
    _asyncCallback = null;
  }

  Future? changeWidget(_WidgetBuilder newWidget) async {
    return _asyncCallback?.call(newWidget);
  }
}

typedef _AsyncCallback = Future Function(_WidgetBuilder newWidget);
typedef _WidgetBuilder = Widget Function();
