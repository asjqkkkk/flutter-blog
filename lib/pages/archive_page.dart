import 'package:flutter/material.dart';
import 'package:flutter_blog/json/tag_item_bean.dart';
import 'package:intl/intl.dart';
import '../json/archive_item_bean.dart';
import '../widgets/web_bar.dart';
import '../widgets/common_layout.dart';

class ArchivePage extends StatefulWidget {
  final List<TagItemBean> beans;


  ArchivePage({this.beans});

  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  List<ArchiveItemBean> beans = [];



  @override
  void initState() {
    if (widget.beans == null) {
      ArchiveItemBean.loadAsset().then((data) {
        beans.addAll(data);
        setState(() {});
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonLayout(
        pageType: PageType.archive,
        child: (widget.beans == null ? beans.isEmpty : false)
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
                      itemCount:widget.beans == null ? beans.length : widget.beans.length,
                      itemBuilder: (ctx, index) {
                        final bean = widget.beans == null ? beans[index] : widget.beans[index];
                        final yearBeans = widget.beans == null ? beans[index].beans : widget.beans[index].beans;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${widget.beans == null ? beans[index].year : widget.beans[index].tag}",
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            Container(
                              margin:
                                  EdgeInsets.only(top: 10, left: 50, right: 50),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                    yearBeans.length, (index2) {
                                  final yearBean =
                                  yearBeans[index2];
                                  return Container(
                                    margin: EdgeInsets.only(top: 8),
                                    child: ListTile(
                                      onTap: () {
                                        showWaitingDialog(context);
                                      },
                                      leading: Text(
                                        "${yearBean.articleName}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                      trailing: Text(
                                        "${getDate(DateTime.parse(yearBean.createTime))}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
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

  String getDate(DateTime time){
    return "${time.year}.${time.month}.${time.day}";
  }
}
