
import 'package:flutter/material.dart';
import 'package:new_web/pages/home_page.dart';

import '../config/all_configs.dart';
import 'all_widgets.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({Key? key, this.onTabSelect, required this.tabs})
      : super(key: key);

  final OnTabSelect? onTabSelect;
  final List<TabWithPage> tabs;

  @override
  _HomeMenuState createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  List<TabWithPage> get tabs => widget.tabs;

  int curIndex = 0;

  @override
  Widget build(BuildContext context) {
    final length = tabs.length;
    return Container(
      margin: EdgeInsets.only(top: v70),
      child: buildSingleChildScrollView(length),
    );
  }

  Widget buildSingleChildScrollView(int length) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buildTabs(length),
      ),
    );
  }

  List<Widget> buildTabs(int length) {
    return List.generate(length, (index) {
      final cur = tabs[index];
      final selected = index == curIndex;
      return RepaintBoundary(
        child: HoverScaleWidget(
          scale: 1.1,
          child: HoverMoveWidget(
            offset: Offset(-v10, 0),
            child: Container(
              width: v240 + v56 - v10,
              height: v60,
              padding: EdgeInsets.only(left: v56 - v10),
              margin: EdgeInsets.only(bottom: index == length - 1 ? 0 : v30),
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  curIndex = index;
                  refresh();
                  widget.onTabSelect?.call(cur.tabInfo, index);
                },
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(v8)),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: v10, right: v10),
                  child: Row(
                    children: [
                      Container(
                        width: v40,
                        height: v40,
                        decoration: BoxDecoration(
                            color: selected ? color4 : color6,
                            borderRadius:
                                BorderRadius.all(Radius.circular(v8))),
                        child: Icon(
                          Icons.star_border_purple500_sharp,
                          color: selected ? Colors.white : color5,
                          size: v14,
                        ),
                      ),
                      SizedBox(width: v25),
                      Text(
                        cur.tabInfo.name,
                        style: CTextStyle(
                            color: selected ? color2 : color5,
                            fontSize: v18,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                            height: 1.0),
                      ),
                      if (selected)
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: v10,
                              height: v10,
                              decoration: const BoxDecoration(
                                color: color4,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}

class TabInfo {
  TabInfo(this.name);

  String name;
}

typedef OnTabSelect = void Function(TabInfo tabInfo, int index);
