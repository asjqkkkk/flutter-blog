import 'package:flutter/material.dart';

class LoadingImage extends StatefulWidget {
  const LoadingImage({
    Key? key,
    this.width,
    this.height,
    this.fit,
    required this.image,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.loadingWidget,
    this.errorWidget,
    this.delayLoading = const Duration(milliseconds: 500),
  }) : super(key: key);

  final double? width;

  final double? height;

  final BoxFit? fit;

  final ImageProvider image;

  final AlignmentGeometry alignment;

  final ImageRepeat repeat;

  final bool matchTextDirection;

  final Widget? loadingWidget;

  final Widget? errorWidget;

  final Duration? delayLoading;

  @override
  _LoadingImageState createState() => _LoadingImageState();
}

class _LoadingImageState extends State<LoadingImage> {
  bool _canLoadImage = false;

  @override
  void initState() {
    final image = widget.image;
    final delayLoading = widget.delayLoading;
    bool needDelay = true;
    if (image is ExactAssetImage && hasLoaded(image.assetName))
      needDelay = false;
    if (needDelay && delayLoading != null)
      Future.delayed(delayLoading, () {
        _canLoadImage = true;
        if (image is ExactAssetImage) _loadedUrl.add(image.assetName);
        refresh();
      });
    else
      _canLoadImage = true;
    super.initState();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_canLoadImage) return buildLoadingWidget();
    return _image(
      image: widget.image,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame == null) return buildLoadingWidget();
        return child;
      },
      errorBuilder: (ctx, error, trace) =>
          widget.errorWidget ?? const SizedBox(),
    );
  }

  Image _image({
    required ImageProvider image,
    ImageErrorWidgetBuilder? errorBuilder,
    ImageFrameBuilder? frameBuilder,
  }) {
    return Image(
      image: image,
      errorBuilder: errorBuilder,
      frameBuilder: frameBuilder,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      matchTextDirection: widget.matchTextDirection,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
  }

  Widget buildLoadingWidget() =>
      widget.loadingWidget ?? const Center(child: CircularProgressIndicator());
}

final Set<String> _loadedUrl = {};

bool hasLoaded(String url) => _loadedUrl.contains(url);
