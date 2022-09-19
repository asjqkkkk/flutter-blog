import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:new_web/json/all_jsons.dart';
import 'package:new_web/pages/article_page.dart';
import 'package:new_web/util/all_utils.dart';
import 'package:new_web/widgets/all_widgets.dart';

import '../config/all_configs.dart';

class HomeItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(v76, v40, v40, v64),
      children: [
        buildRow1(),
        buildRow2(),
        buildRow3(),
      ],
    );
  }

  Widget buildRow1() {
    return Padding(
      padding: EdgeInsets.only(bottom: v40),
      child: Row(
        children: [
          buildBox1(_box1),
          SizedBox(width: v40),
          buildBox2(_box2),
        ],
      ),
    );
  }

  Widget buildBox1(ArticleItemBean bean) {
    final time = DateTime.tryParse(bean.createTime!)!;
    return HoverMoveWidget(
      offset: Offset(0, -v20),
      child: CusInkWell(
        borderRadius: BorderRadius.circular(v20),
        onTap: () => pushArticle(bean),
        child: Container(
          height: v280,
          width: v400 + v280,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(v20),
                boxShadow: boxShadows),
            padding: EdgeInsets.all(v10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: v260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(v12),
                      gradient: cusGradient,
                    ),
                    child: SvgPicture.asset(
                      Svg.home1,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(v32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bean.tag!,
                          style: CTextStyle(
                              fontSize: v14, color: cusGradient.colors[0]),
                        ),
                        SizedBox(height: v24),
                        Text(
                          bean.articleName!,
                          style: CTextStyle(
                            fontSize: v22,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: v24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getDate(time),
                              style: CTextStyle(
                                fontSize: v16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: v8),
                            Text(
                              getTime(time),
                              style: CTextStyle(
                                fontSize: v12,
                                color: cusGradient.colors[0],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future pushArticle(ArticleItemBean bean) {
    return RouteConfig.instance.push(RouteConfig.article,
        arguments: ArticleArg(bean.articleId, bean.articlePath));
  }

  Widget buildBox2(ArticleItemBean bean) {
    final time = DateTime.tryParse(bean.createTime!)!;
    return HoverMoveWidget(
      offset: Offset(0, -v20),
      child: CusInkWell(
        borderRadius: BorderRadius.circular(v20),
        onTap: () => pushArticle(bean),
        child: Container(
          height: v280,
          width: v320,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(v20),
                boxShadow: boxShadows),
            padding: EdgeInsets.all(v10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: v115,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(v12), color: color8),
                  child: SvgPicture.asset(Svg.home3),
                ),
                Padding(
                  padding: EdgeInsets.all(v10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bean.articleName!,
                        style: CTextStyle(
                          fontSize: v22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                      ),
                      SizedBox(height: v8),
                      Text(
                        bean.summary!,
                        style: CTextStyle(
                          fontSize: v14,
                          color: color24,
                          height: 1.25,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.clip,
                      ),
                      SizedBox(height: v8),
                      Text(
                        '${getDate(time)}   ${getTime(time)}   --[${bean.tag}]',
                        style: CTextStyle(
                          fontSize: v12,
                          color: cusGradient.colors[0],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow2() {
    return Padding(
      padding: EdgeInsets.only(bottom: v40),
      child: Row(
        children: List.generate(3, (i) {
          final bean = _rows[i];
          return Container(
            height: v140,
            width: v320,
            margin: EdgeInsets.only(left: i > 0 ? v40 : 0),
            child: HoverMoveWidget(
              offset: Offset(0, -v20),
              child: CusInkWell(
                borderRadius: BorderRadius.circular(v20),
                onTap: () => toLaunch(bean.link!),
                child: Container(
                  padding: EdgeInsets.all(v10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(v20),
                      boxShadow: boxShadows),
                  child: Row(
                    children: [
                      Container(
                        width: v120,
                        height: v120,
                        decoration: BoxDecoration(
                          color: color8,
                          borderRadius: BorderRadius.circular(v20),
                        ),
                        child: SvgPicture.asset(bean.imgPath!),
                      ),
                      SizedBox(width: v20),
                      Expanded(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bean.des!,
                            style: CTextStyle(
                                fontSize: v14, color: cusGradient.colors[0]),
                          ),
                          SizedBox(height: v16),
                          Text(
                            bean.title!,
                            style: CTextStyle(
                              fontSize: v22,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ))
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget buildRow3() {
    return Row(
      children: [
        buildBox3(),
        SizedBox(
          width: v40,
        ),
        buildBox4(),
      ],
    );
  }

  HoverMoveWidget buildBox4() {
    return HoverMoveWidget(
      offset: Offset(0, -v20),
      child: CusInkWell(
        borderRadius: BorderRadius.circular(v20),
        onTap: () =>
            toLaunch('https://weread.qq.com/web/reader/ce032b305a9bc1ce0b0dd2a'),
        child: Container(
          height: v300,
          width: v130,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(v20),
                boxShadow: boxShadows),
            padding: EdgeInsets.all(v10),
            child: Column(
              children: [
                Container(
                  height: v115,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(v12),
                      color: color8,
                      image: const DecorationImage(
                        image: ExactAssetImage(
                            '${PathConfig.assets}/img/box4.png'),
                        fit: BoxFit.cover,
                      )),
                ),
                SizedBox(height: v16),
                Text(
                  '《三体》\n自 我 渺 小\n宇 宙 浩 瀚',
                  textAlign: TextAlign.center,
                  style: CTextStyle(
                    fontSize: v18,
                    color: Colors.black,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: v16),
                buildTag(color25, '一起看')
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBox3() {
    final richStyle = CTextStyle(fontSize: v16, color: color26, height: 2);
    return HoverMoveWidget(
      offset: Offset(0, -v20),
      child: CusInkWell(
        borderRadius: BorderRadius.circular(v20),
        onTap: () => toLaunch('https://github.com/asjqkkkk'),
        child: Container(
          height: v300,
          width: v400 * 2 + v70,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(v20),
                boxShadow: boxShadows),
            padding: EdgeInsets.all(v10),
            child: Container(
              height: v280,
              padding: EdgeInsets.fromLTRB(v48, v36, v48, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(v12),
                color: color13,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildTag(color25, '开 源'),
                        SizedBox(height: v26),
                        Text(
                          '下面这些，是我正投入时间精力，持续维护更新的一些开源库',
                          style: CTextStyle(
                              fontSize: v22,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              height: 1.5),
                          maxLines: 2,
                        ),
                        SizedBox(height: v16),
                        RichText(
                          text: TextSpan(style: richStyle, children: [
                            buildLinkSpan('markdown_widget', richStyle,
                                left: '[',
                                right: '], ',
                                onTap: () => toLaunch(
                                    'https://github.com/asjqkkkk/markdown_widget')),
                            buildLinkSpan('memory_checker', richStyle,
                                left: '[',
                                right: '],',
                                onTap: () => toLaunch(
                                    'https://github.com/asjqkkkk/memory_checker')),
                            buildLinkSpan('flutter-blog', richStyle,
                                left: '\n[',
                                right: ']',
                                onTap: () => toLaunch(
                                    'https://github.com/asjqkkkk/flutter-blog')),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset(Svg.home2, width: v300),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextSpan buildLinkSpan(String text, TextStyle style,
      {GestureTapCallback? onTap, String? left, String? right}) {
    return TextSpan(
      children: [
        if (left != null) TextSpan(text: left, style: style),
        TextSpan(
          text: text,
          style: style.copyWith(color: Colors.blueAccent),
          recognizer: TapGestureRecognizer()..onTap = onTap,
        ),
        if (right != null) TextSpan(text: right, style: style),
      ],
    );
  }

  Widget buildTag(Color color, String text) {
    return Container(
      padding: EdgeInsets.fromLTRB(v24, v8, v24, v8),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(v4)),
      child: Text(
        text,
        style: CTextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: v14,
        ),
      ),
    );
  }
}

// ignore: flutter_style_todos
///TODO:目前主页的数据格式暂时没想好，后面不会使用这种写死的
ArticleItemBean _box1 = ArticleItemBean.fromMap({
  'articleName': '从源码看flutter（五）：GestureDetector篇',
  'createTime': '2020-04-23T10:43:35.000',
  'lastModifiedTime': '2021-05-06T23:51:16.000',
  'tag': 'Flutter系列',
  'summary': '开篇 flutter的触摸事件涉及到的东西比较多，本篇文章将会从   GestureDetector',
  'imageAddress': '/img/flutter_05.png',
  'articleAddress': 'temp/input/study/从源码看flutter（五）：GestureDetector篇.md',
  'articleId': '5bb7aebf',
  'articlePath': 'study'
});

ArticleItemBean _box2 = ArticleItemBean.fromMap({
  'articleName': '周六闲记',
  'createTime': '2021-05-22T11:54:21.000',
  'lastModifiedTime': '2021-05-23T00:00:15.000',
  'tag': '杂谈',
  'summary':
      '头 似乎每次放假的周末，都是没有早晨的。在被手机消息唤醒的那一刻，也预示午饭时间快到了 完成各种繁琐的起床步骤后，吃了桶泡面，看了会儿《模范出租车》，又睡到了三点多 深圳的中午还是一 ',
  'imageAddress': '/img/2021_05_22.png',
  'articleAddress': 'temp/input/life/周六闲记.md',
  'articleId': '9cf75a87',
  'articlePath': 'life'
});

class _RowData {
  _RowData({this.imgPath, this.title, this.des, this.link});

  final String? imgPath;
  final String? title;
  final String? des;
  final String? link;
}

List<_RowData> _rows = [
  _RowData(
    imgPath: Svg.home4,
    title: '我的掘金',
    des: '文章',
    link: 'https://juejin.cn/user/1591748567765480',
  ),
  _RowData(
    imgPath: Svg.home5,
    title: '观影清单',
    des: '豆瓣',
    link: 'https://movie.douban.com/top250',
  ),
  _RowData(
    imgPath: Svg.home6,
    title: '经典书籍',
    des: '豆瓣',
    link: 'https://book.douban.com/top250',
  ),
];
