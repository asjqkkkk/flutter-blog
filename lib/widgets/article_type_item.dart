import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/json/article_item_bean.dart';
import 'package:new_web/pages/article_page.dart';
import 'package:new_web/util/all_utils.dart';

import 'all_widgets.dart';

class ArticleTypeItem extends StatelessWidget {
  const ArticleTypeItem({
    Key? key,
    required this.article,
    required this.articlePath,
  }) : super(key: key);

  final ArticleItemBean article;
  final String articlePath;

  String? get imagePath => article.imageAddress;

  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  String get realImagePath => 'assets$imagePath';

  String get createTime => article.getCreateTime();

  String get title => article.articleName ?? '';

  String get summary => article.summary ?? '';

  String get id => article.articleId ?? '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: v210,
      padding: EdgeInsets.only(bottom: v30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HoverMoveWidget(
            child: CusInkWell(
              child: buildImage(),
              onTap: () {
                RouteConfig.instance.push(RouteConfig.article,
                    arguments: ArticleArg(id, articlePath));
              },
            ),
            offset: Offset(0, -v20),
          ),
          Padding(
            padding: EdgeInsets.only(top: v20, bottom: v10),
            child: Text(
              createTime,
              style: CTextStyle(
                fontSize: v14,
                color: color23,
                height: 1,
              ),
              maxLines: 1,
            ),
          ),
          Text(
            title,
            style: CTextStyle(
              fontSize: v18,
              color: Colors.black,
              height: 1.25,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 3,
            overflow: TextOverflow.clip,
          ),
          if (summary.isNotEmpty) ...[
            SizedBox(height: v10),
            Text(
              summary,
              style: CTextStyle(
                fontSize: v14,
                color: color24,
                height: 1.25,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 3,
              overflow: TextOverflow.clip,
            ),
          ],
        ],
      ),
    );
  }

  Widget buildImage() {
    return hasImage
        ? Container(
            width: v210,
            height: v127,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(v6),
              child: LoadingImage(
                image:
                    buildResizeImage(ExactAssetImage(realImagePath), h: v127),
                fit: BoxFit.cover,
                loadingWidget: Container(
                    width: v210,
                    height: v127,
                    decoration: BoxDecoration(
                        color: randomColor,
                        borderRadius: BorderRadius.circular(v6))),
              ),
            ),
          )
        : Container(
            width: v210,
            height: v127,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(v6),
              color: randomColor,
            ),
            child: Center(
              child: Icon(
                Icons.image,
                color: Colors.white,
                size: v50,
              ),
            ),
          );
  }
}
