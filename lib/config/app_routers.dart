import 'package:flutter/material.dart';
import 'package:flutter_blog/pages/all_pages.dart';
import '../main.dart';
import 'base_config.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppModule extends MainModule {

  // here will be any class you want to inject into your project (eg bloc, dependency)
  @override
  List<Bind> get binds => [];

  // here will be the routes of your module
  @override
  List<Router> get routers => [
    Router(homePage, child: (_, args) => HomePage()),
    Router(tagPage, child: (_, args) => TagPage()),
    Router(archivePage, child: (_, args) => ArchivePage()),
    Router(linkPage, child: (_, args) => FriendLinkPage()),
    Router(aboutPage, child: (_, args) => AboutPage()),
    Router("$articlePage/:name", child: (_, args) => ArticlePage(name: args.params['name'], articleData: args.data,)),
  ];

// add your main widget here
  @override
  Widget get bootstrap => MyApp();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ///强制横屏
//    SystemChrome.setPreferredOrientations([
//      DeviceOrientation.landscapeLeft,
//      DeviceOrientation.landscapeRight,
//    ]);
    final int curHour = DateTime.now().hour;
    return MaterialApp(
      title: '老晨子的flutter blog',
      theme: ThemeData(
        brightness:
        (curHour > 18 || curHour < 7) ? Brightness.dark : Brightness.light,
      ),
      initialRoute: homePage,
//      routes: {
//        homePage: (BuildContext context) => HomePage(),
//        tagPage: (BuildContext context) => TagPage(),
//        archivePage: (BuildContext context) => ArchivePage(),
//        linkPage: (BuildContext context) => FriendLinkPage(),
//        aboutPage: (BuildContext context) => AboutPage(),
//      },
      onGenerateRoute: Modular.generateRoute,
//      onGenerateRoute: (settings) {
//        if (settings.name == articlePage) {
//          return _pageRoute(ArticlePage(
//            articleData: settings.arguments,
//          ));
//        } else
//          return _pageRoute(HomePage());
//      },
    );
  }

  MaterialPageRoute _pageRoute(Widget widget) {
    return MaterialPageRoute(builder: (ctx) => widget);
  }
}