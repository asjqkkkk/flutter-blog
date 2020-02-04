import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class LoadingImage extends StatelessWidget {

  final String url;

  const LoadingImage({Key key,@required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder(
      // Paste your image URL inside the htt.get method as a parameter
      future: http.get(url),
      builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('加载图片...');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          case ConnectionState.done:
            if (snapshot.hasError)
              return Text('图片加载错误: ${snapshot.error}');
            // when we get the data from the http call, we give the bodyBytes to Image.memory for showing the image
            return Image.memory(snapshot.data.bodyBytes);
        }
        return null; // unreachable
      },
    );
  }
}
