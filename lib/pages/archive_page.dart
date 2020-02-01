import 'package:flutter/material.dart';
import 'package:flutter_blog/json/archive_item_bean.dart';
import 'package:flutter_blog/widgets/web_bar.dart';
import 'package:intl/intl.dart';
import '../widgets/common_layout.dart';

class ArchivePage extends StatefulWidget {
  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  List<ArchiveItemBean> beans = [];

  @override
  void initState() {
    ArchiveItemBean.loadAsset().then((data) {
      beans.addAll(data);
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonLayout(
        pageType: PageType.archive,
        child: beans.isEmpty
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                margin: EdgeInsets.only(top: 50, left: 50, right: 50),
                child: Card(
                  margin: EdgeInsets.only(bottom: 0.0),
                  child: Container(
                    margin: EdgeInsets.only(top: 20, left: 50, right: 50),
                    child: ListView.builder(
                      itemCount: beans.length,
                      itemBuilder: (ctx, index) {
                        ArchiveItemBean archiveItemBean = beans[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${beans[index].year}",
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            Container(
                                margin: EdgeInsets.only(
                                    top: 10, left: 50, right: 50),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                      archiveItemBean.beans.length, (index2) {
                                    final yearBean =
                                        archiveItemBean.beans[index2];
                                    return Container(
                                      margin: EdgeInsets.only(top: 8),
                                      child: ListTile(
                                        onTap: (){
                                          showWaitingDialog(context);
                                        },
                                        leading: Text(
                                          "${yearBean.articleName}",
                                          style:
                                          Theme.of(context).textTheme.subtitle1,
                                        ),
                                        trailing: Text(
                                          "${DateFormat.yMd().format(DateTime.parse(yearBean.createTime))}",
                                          style:
                                          Theme.of(context).textTheme.subtitle1,
                                        ),
                                      ),
                                    );
                                  }),
                                ))
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void showWaitingDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            content: Text("功能尚在开发中..."),
          );
        });
  }
}
