import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';
import 'config/configure_nonweb.dart'
    if (dart.library.html) 'config/configure_web.dart';
import 'pages/all_pages.dart';

void main() {
  ///去掉web端url中的#
  configureApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小李的博客',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      navigatorKey: GlobalData.instance.globalKey,
      initialRoute: RouteConfig.home,
      onGenerateRoute: RouteConfig.instance.onGenerateRoute,
    );
  }
}
