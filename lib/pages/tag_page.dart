import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../json/tag_item_bean.dart';
import '../widgets/common_layout.dart';
import '../widgets/web_bar.dart';
import 'dart:math';

import 'archive_page.dart';

class TagPage extends StatefulWidget {
  @override
  _TagPageState createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  List<TagItemBean> beans = [];

  @override
  void initState() {
    TagItemBean.loadAsset().then((data) {
      beans.addAll(data);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: CommonLayout(
        pageType: PageType.tag,
        child: Container(
          margin: EdgeInsets.only(top: 80, left: width / 10, right: width / 10),
          child: Card(
            child: beans.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    alignment: Alignment.center,
                    height: height / 2,
                    child: SingleChildScrollView(
                      child: Wrap(
                        children: List.generate(beans.length, (index) {
                          final bean = beans[index];
                          return FlatButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(new MaterialPageRoute(builder: (ctx) {
                                return ArchivePage(
                                  beans: [bean],
                                );
                              }));
                            },
                            child: Text(
                              bean.tag,
                              style: TextStyle(
                                fontSize: (Random().nextInt(40) + 20).toDouble(),
                                color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
