import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/widgets/all_widgets.dart';

class AboutItem extends StatefulWidget {
  @override
  _AboutItemState createState() => _AboutItemState();
}

class _AboutItemState extends State<AboutItem> {
  final _curIndexListener = ValueNotifier(0);

  final _controller = ColorController();
  final _switcherController = SwitcherController();
  final _indicatorController = IndicatorController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: v400 * 2 + v240,
      padding:
          EdgeInsets.only(bottom: v64, top: v110, left: v76, right: v160 - v76),
      child: buildBody(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _switcherController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  Widget buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(),
        buildIndicator(),
        Text(
          ' 关于我的',
          style:
              CTextStyle(fontWeight: FontWeight.bold, fontSize: v20, height: 1),
        ),
        buildFooter(),
      ],
    );
  }

  Widget buildHeader() {
    final cur = gameItems[curIndex];
    return RepaintBoundary(
      child: Stack(
        children: [
          AnimatedColorWidget(
              duration: const Duration(seconds: 1),
              colorController: _controller,
              colorData: ColorData(cur.colors[0], cur.colors[1]),
              colorWidgetBuilder: (context, colorData) {
                return Container(
                  height: v316,
                  width: v400 * 2 + v240,
                  decoration: BoxDecoration(
                    gradient: buildGradient([
                      colorData.begin!,
                      colorData.end!,
                    ]),
                    borderRadius: BorderRadius.circular(v20),
                    boxShadow: boxShadows,
                  ),
                );
              }),
          Container(
            height: v316,
            width: v400 * 2 + v240,
            child: ValueListenableBuilder(
                valueListenable: _curIndexListener,
                builder: (ctx, dynamic value, _) {
                  final cur = gameItems[curIndex];
                  return CustomAnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    switcherController: _switcherController,
                    childBuilder: () => GameTypeItem(gameItem: cur),
                  );
                }),
          )
        ],
      ),
    );
  }

  Widget buildIcon(String path, {double? size}) {
    return SvgPicture.asset(
      path,
      width: size ?? v64,
      height: size ?? v64,
    );
  }

  Widget buildIndicator() {
    return ValueListenableBuilder(
        valueListenable: _curIndexListener,
        builder: (ctx, dynamic value, _) {
          return Container(
            height: v40,
            margin: EdgeInsets.only(top: v40, bottom: v38),
            child: RepaintBoundary(
              child: RowIndicator(
                limitSize: v24,
                duration: const Duration(seconds: 1),
                indicatorController: _indicatorController,
                children: List.generate(itemCount, (index) {
                  final cur = gameItems[index];
                  return Center(
                    child: Container(
                      width: v24,
                      height: v24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: buildGradient(cur.colors),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        });
  }

  Widget buildFooter() {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, index) {
          final isFirst = index == 0;
          final cur = gameItems[index];
          final iconPath = cur.iconPath;
          return HoverMoveWidget(
            offset: Offset(0, -v20),
            child: CusInkWell(
              onTap: () => changeSelected(index),
              child: Container(
                width: v180,
                height: v235,
                margin: EdgeInsets.only(left: isFirst ? 0 : v40, top: v40),
                padding: EdgeInsets.all(v20),
                decoration: BoxDecoration(
                  gradient: buildGradient(cur.colors),
                  borderRadius: BorderRadius.circular(v8),
                  boxShadow: boxShadows,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [buildIcon(iconPath, size: v48)],
                ),
              ),
            ),
          );
        },
        itemCount: itemCount,
      ),
    );
  }

  void changeSelected(int index) {
    if (curIndex == index) return;
    _curIndexListener.value = index;
    final cur = gameItems[index];
    final colors = cur.colors;
    _controller.changeColor(ColorData(colors[0], colors[1]));
    _switcherController.changeWidget(() => GameTypeItem(gameItem: cur));
    _indicatorController.changeIndex(index);
  }

  LinearGradient buildGradient(List<Color> colors) {
    return LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors);
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  int get itemCount => gameItems.length;

  int get curIndex => _curIndexListener.value;
}

final List<GameItem> gameItems = [
  // GameItem(colors6, Svg.iconFlutter),
  GameItem(
    colors1,
    Svg.iconXBox,
    Svg.bgXBox,
    '我的 XBOX',
    '自从买了xbox series x之后，一直都是一个人在玩，来加我的好友吧！',
    'https://account.xbox.com/zh-cn/Profile?Gamertag=GoldRiver664349&rtc=1',
    '主 页',
  ),
  GameItem(
    colors2,
    Svg.iconSteam,
    Svg.bgSteam,
    '我的 Steam ',
    '算是个老steam玩家了，如果平时工作不忙的话，也会常常上线看看，有兴趣的小伙伴也可以加个好友，备注博客来的哦',
    'https://steamcommunity.com/id/JiangHun/',
    '主 页',
  ),
  GameItem(
    colors3,
    Svg.iconGMail,
    Svg.bgGMail,
    '我的 Gmail ',
    '如果有什么想要联系我的，可以给我的Gmail发邮件，虽然回复频率可能没有那么快，不过看到了一定会答复的',
    'mailto:agedchen@gamil.com',
    '主 页',
  ),
  GameItem(
    colors4,
    Svg.iconGithub,
    Svg.bgGithub,
    '我的 Github',
    '目前开源了好几个关于flutter的项目，不过一个人精力实在有限，不过还是欢迎小伙伴提issue，同时非常欢迎规范的pr',
    'https://github.com/asjqkkkk',
    '主 页',
  ),
  GameItem(
    colors5,
    Svg.iconPS,
    Svg.bgPlaystation,
    '我的 PS5 ',
    '国行PS5已经出了，目前还在观望中，迟早会买的，等我有了账号再把相关内容放上来吧',
    null,
    '主 页',
  ),
];

class GameItem {
  GameItem(
    this.colors,
    this.iconPath,
    this.bgPath,
    this.title,
    this.description,
    this.link,
    this.linkDes,
  );

  final List<Color> colors;
  final String iconPath;
  final String bgPath;
  final String title;
  final String description;
  final String? link;
  final String linkDes;
}
