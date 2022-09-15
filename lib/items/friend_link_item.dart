import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/json/friend_link.dart';
import 'package:new_web/util/all_utils.dart';
import 'package:new_web/widgets/all_widgets.dart';

class FriendLinkItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: GlobalData.instance.friendData,
        builder: (ctx, dynamic value, _) {
          if (value == null) return buildEmptyLayout();
          return _FriendLinkItem(links: value);
        });
  }
}

class _FriendLinkItem extends StatelessWidget {
  const _FriendLinkItem({
    Key? key,
    required this.links,
  }) : super(key: key);

  final List<FriendLinkBean> links;

  int get linkLength => links.length;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: v400 * 2 + v240,
      margin:
          EdgeInsets.only(bottom: v64, top: 0, left: v76, right: v160 - v76),
      child: buildBody(),
    );
  }

  Widget buildBody() {
    return SelectionArea(
      child: ListView.builder(
        padding: EdgeInsets.only(top: v110),
        itemBuilder: (ctx, index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _crossCount,
              (i) {
                final isFirstInRow = i == 0;
                final curIndex = index * _crossCount + i;
                final isOver = curIndex + 1 > linkLength;
                return Padding(
                  padding: EdgeInsets.only(left: isFirstInRow ? 0 : v66),
                  child: isOver
                      ? SizedBox(width: v180, height: v280)
                      : RepaintBoundary(
                          child: _Item(friendLinkBean: links[curIndex])),
                );
              },
            ),
          );
        },
        itemCount: (linkLength / _crossCount).ceil(),
      ),
    );
  }
}

const int _crossCount = 4;

class _Item extends StatelessWidget {
  const _Item({Key? key, required this.friendLinkBean}) : super(key: key);

  final FriendLinkBean friendLinkBean;

  @override
  Widget build(BuildContext context) {
    return HoverScaleWidget(
      child: Container(
        width: v180,
        height: v280,
        margin: EdgeInsets.only(bottom: v40),
        decoration: BoxDecoration(
          color: color19,
          borderRadius: BorderRadius.circular(v12),
          boxShadow: boxShadows,
        ),
        child: Stack(
          children: [
            Shimmer(
              radius: v12,
              baseColor: color19,
              duration: const Duration(milliseconds: 2500),
              highlightColor: color20,
              child: Container(
                  width: v180,
                  height: v280,
                  decoration: BoxDecoration(
                    color: color19,
                    borderRadius: BorderRadius.circular(v12),
                  )),
            ),
            Center(
              child: Column(
                children: [
                  Container(
                    width: v64,
                    height: v64,
                    margin: EdgeInsets.only(top: v48, bottom: v16),
                    child: HoverRotateWidget(
                      child: Container(
                          width: v64,
                          height: v64,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: buildResizeImage(
                                      ExactAssetImage(
                                          friendLinkBean.assetAvatar ?? ''),
                                      w: v64,
                                      h: v64)))),
                    ),
                  ),
                  Text(
                    friendLinkBean.linkName!,
                    style: CTextStyle(
                      color: color20,
                      fontWeight: FontWeight.bold,
                      fontSize: v20,
                    ),
                  ),
                  SizedBox(height: v16),
                  Text(
                    friendLinkBean.profession!,
                    style: CTextStyle(
                      color: color20,
                      fontSize: v10,
                    ),
                  ),
                  Container(
                    height: v3,
                    width: v10,
                    margin: EdgeInsets.only(top: v16, bottom: v24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(v1),
                      color: color21,
                    ),
                  ),
                  CusInkWell(
                    child: Container(
                      width: v60,
                      height: v20,
                      decoration: BoxDecoration(
                          color: color21,
                          borderRadius: BorderRadius.circular(v4)),
                      child: Center(
                        child: Text(
                          '进 入',
                          style: CTextStyle(
                              fontSize: v10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1),
                        ),
                      ),
                    ),
                    onTap: () {
                      launch(friendLinkBean.linkAddress!);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
