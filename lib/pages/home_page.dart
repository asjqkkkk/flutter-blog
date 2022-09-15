
import 'package:flutter/material.dart';
import 'package:new_web/items/about_item.dart';
import 'package:new_web/items/all_items.dart';

import '../config/all_configs.dart';
import '../util/all_utils.dart';
import '../widgets/all_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _StateDelegate _stateDelegate = _StateDelegate();
  late HomePageModel _model;

  @override
  void initState() {
    _stateDelegate._refreshCallback = _refresh;
    _model = HomePageModel(_stateDelegate);
    _model.context ??= context;
    _model.initState();
    super.initState();
  }

  @override
  void dispose() {
    _stateDelegate._refreshCallback = null;
    _model.dispose();
    super.dispose();
  }

  void _refresh() => _stateDelegate.refresh();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    final logic = _model.logic;
    return Scaffold(
      body: logic.buildBody(),
    );
  }
}

class HomePageModel {
  HomePageModel(this.stateDelegate) {
    logic = HomePageLogic(this);
  }

  final _StateDelegate stateDelegate;
  late HomePageLogic logic;
  BuildContext? context;

  List<TabWithPage> pages = [
    TabWithPage(TabInfo('主 页', Icons.home_outlined), () => HomeItems()),
    TabWithPage(TabInfo('一 则', Icons.star_border_purple500_sharp),
        () => OneLineItems()),
    TabWithPage(
        TabInfo('友 链', Icons.people_alt_outlined), () => FriendLinkItem()),
    TabWithPage(TabInfo('关 于', Icons.account_box_outlined), () => AboutItem()),
    TabWithPage(
        TabInfo('游 戏', Icons.videogame_asset_outlined), () => GameScreenItem()),
    TabWithPage(TabInfo('文 章', Icons.article_outlined), () => ArticleItem()),
  ];

  int get pageCount => pages.length;

  final PageController pageController = PageController();

  final _curIndex = ValueNotifier(0);

  int get curIndex => _curIndex.value;

  void initState() {
    GlobalData.instance.initialData();
  }

  void dispose() {}

  void refresh() => stateDelegate.refresh();
}

class HomePageLogic {
  HomePageLogic(this._model);

  final HomePageModel _model;

  Widget buildBody() {
    return Center(
      child: SelectionArea(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildLeftLayout(),
            buildRightLayout(),
          ],
        ),
      ),
    );
  }

  Widget buildLeftLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(),
        buildDate(),
        buildHomeMenu(),
        buildMusicWidget(),
      ],
    );
  }

  Widget buildRightLayout() {
    final model = _model;
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        WebBar(),
        Expanded(
            child: Container(
          width: v400 * 3,
          child: ValueListenableBuilder(
              valueListenable: model._curIndex,
              builder: (context, dynamic index, _) {
                return model.pages[index]._widgetBuilder.call();
              }),
        )),
      ],
    );
  }

  Widget buildHeader() {
    const headImage = ExactAssetImage('assets/img/head.png');
    return Container(
      margin: EdgeInsets.only(left: v56, top: v58),
      child: HoverRotateWidget(
        child: CusInkWell(
          // onTap: () {
          //   FullScreenDialog.getInstance().showDialog(
          //     GlobalData.instance.context,
          //     TopAnimationShowWidget(
          //       child: GestureDetector(
          //         onTap: () => Navigator.of(GlobalData.instance.context).pop(),
          //         child: Scaffold(
          //           backgroundColor: Colors.transparent,
          //           body: Container(
          //             child: Image(image: headImage),
          //             alignment: Alignment.topLeft,
          //           ),
          //         ),
          //       ),
          //       distanceY: MediaQuery.of(_model.context).size.height / 2,
          //     ),
          //   );
          // },
          child: Container(
            width: v64,
            height: v64,
            decoration: BoxDecoration(
                color: color1,
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: buildResizeImage(headImage, w: v64, h: v64))),
          ),
        ),
      ),
    );
  }

  Widget buildDate() => const DateWidget();

  Widget buildHomeMenu() {
    final model = _model;
    return Expanded(
      child: HomeMenu(
        onTabSelect: (info, index) {
          if (index == model.curIndex) return;
          model._curIndex.value = index;
        },
        tabs: model.pages,
      ),
    );
  }

  Widget buildMusicWidget() {
    return RepaintBoundary(child: MusicWidget());
  }
}

class _StateDelegate {
  VoidCallback? _refreshCallback;

  void refresh() => _refreshCallback?.call();
}

typedef _WidgetBuilder = Widget Function();

class TabWithPage {
  TabWithPage(this.tabInfo, this._widgetBuilder);

  final TabInfo tabInfo;
  final _WidgetBuilder _widgetBuilder;
}
