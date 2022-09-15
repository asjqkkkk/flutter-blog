import 'package:flutter/material.dart';

class ShimmerAnimator extends StatefulWidget {
  const ShimmerAnimator({
    this.child,
    this.highlightColor,
    this.baseColor,
    this.duration,
    this.interval,
    this.direction,
    this.radius,
  });

  final Color? highlightColor;
  final Color? baseColor;
  final Duration? duration;
  final Duration? interval;
  final double? radius;
  final ShimmerDirection? direction;
  final Widget? child;

  @override
  _ShimmerAnimatorState createState() => _ShimmerAnimatorState();
}

//Animator state controls the animation using all the parameters defined
class _ShimmerAnimatorState extends State<ShimmerAnimator>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: widget.duration);
    animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0, 1, curve: Curves.decelerate),
    ))
      ..addListener(() async {
        if (controller.isCompleted)
          Future.delayed(widget.interval!, () {
            if (mounted) {
              controller.repeat();
            }
          });
        setState(() {});
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: CustomSplashAnimation(
        context: context,
        position: animation.value,
        highlightColor: widget.highlightColor,
        baseColor: widget.baseColor,
        begin: widget.direction!.begin,
        end: widget.direction!.end,
        radius: widget.radius,
      ),
      child: widget.child,
    );
  }
}

class CustomSplashAnimation extends CustomPainter {
  CustomSplashAnimation({
    this.context,
    this.position,
    this.highlightColor,
    this.baseColor,
    this.begin,
    this.end,
    this.radius,
  });

  final double? radius;
  final BuildContext? context;
  double? position;
  double width = 0.3;
  final Color? highlightColor;
  final Color? baseColor;
  final Alignment? begin, end;

  //Custom Painter to paint one frame of the animation. This is called in a loop to animate
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
//    position = 0.7;
    paint.style = PaintingStyle.fill;
    final stops = [
      position!,
      if ((position! + width) > 1) 1.0 else position! + width,
      if ((position! + width + 0.2) > 1) 1.0 else position! + width + 0.2
    ];
    paint.shader = LinearGradient(
      tileMode: TileMode.clamp,
      begin: begin!,
      end: end!,
      colors: <Color>[
        baseColor!,
        highlightColor!,
        baseColor!,
      ],
      stops: stops,
    ).createShader(
        Rect.fromLTRB(-size.width / 2, 0, size.width * 1.5, size.height));
    final RRect borderRect = BorderRadius.circular(radius ?? 0.0)
        .toRRect(Rect.fromPoints(Offset.zero, Offset(size.width, size.height)));
    canvas.drawRRect(borderRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Shimmer extends StatelessWidget {
  const Shimmer({
    this.child,
    this.enabled = true,
    this.highlightColor = Colors.white,
    this.radius,
    required this.baseColor,
    this.duration = const Duration(seconds: 3),
    this.interval = const Duration(seconds: 0),
    this.direction = const ShimmerDirection.fromLTRB(),
  });

  final Widget? child;

  final bool enabled;

  final Color highlightColor;

  final Color baseColor;

  final Duration duration;

  final Duration interval;

  final ShimmerDirection direction;

  final double? radius;

  @override
  Widget build(BuildContext context) {
    if (enabled)
      return ShimmerAnimator(
        child: child,
        highlightColor: highlightColor,
        baseColor: baseColor,
        duration: duration,
        interval: interval,
        direction: direction,
        radius: radius,
      );
    else
      return child!;
  }
}

/// A direction along which the shimmer animation will travel
///
///
/// Shimmer animation can travel in 6 possible directions:
///
/// Diagonal Directions:
/// - [ShimmerDirection.fromLTRB] : animation starts from Left Top and moves towards the Right Bottom. This is also the default behaviour if no direction is specified.
/// - [ShimmerDirection.fromRTLB] : animation starts from Right Top and moves towards the Left Bottom
/// - [ShimmerDirection.fromLBRT] : animation starts from Left Bottom and moves towards the Right Top
/// - [ShimmerDirection.fromRBLT] : animation starts from Right Bottom and moves towards the Left Top
///
/// Directions along the axes:
/// - [ShimmerDirection.fromLeftToRight] : animation starts from Left Center and moves towards the Right Center
/// - [ShimmerDirection.fromRightToLeft] : animation starts from Right Center and moves towards the Left Center
class ShimmerDirection {
  factory ShimmerDirection() => const ShimmerDirection._fromLTRB();

  const ShimmerDirection._fromLTRB({
    this.begin = Alignment.topLeft,
    this.end = Alignment.centerRight,
  });

  const ShimmerDirection._fromRTLB({
    this.begin = Alignment.centerRight,
    this.end = Alignment.topLeft,
  });

  const ShimmerDirection._fromLBRT({
    this.begin = Alignment.bottomLeft,
    this.end = Alignment.centerRight,
  });

  const ShimmerDirection._fromRBLT({
    this.begin = Alignment.topRight,
    this.end = Alignment.centerLeft,
  });

  const ShimmerDirection._fromLeftToRight({
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  const ShimmerDirection._fromRightToLeft({
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  /// Animation starts from Left Top and moves towards the Right Bottom
  const factory ShimmerDirection.fromLTRB() = ShimmerDirection._fromLTRB;

  /// Animation starts from Right Top and moves towards the Left Bottom
  const factory ShimmerDirection.fromRTLB() = ShimmerDirection._fromRTLB;

  /// Animation starts from Left Bottom and moves towards the Right Top
  const factory ShimmerDirection.fromLBRT() = ShimmerDirection._fromLBRT;

  /// Animation starts from Right Bottom and moves towards the Left Top
  const factory ShimmerDirection.fromRBLT() = ShimmerDirection._fromRBLT;

  /// Animation starts from Left Center and moves towards the Right Center
  const factory ShimmerDirection.fromLeftToRight() =
      ShimmerDirection._fromLeftToRight;

  /// Animation starts from Right Center and moves towards the Left Center
  const factory ShimmerDirection.fromRightToLeft() =
      ShimmerDirection._fromRightToLeft;

  final Alignment begin, end;
}
