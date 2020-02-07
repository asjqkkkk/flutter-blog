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

    final isNotMobile = !PlatformDetector().isMobile();


    return Scaffold(
      body: CommonLayout(
        pageType: PageType.archive,
        child: (widget.beans == null ? beans.isEmpty : false)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                margin: isNotMobile ? const EdgeInsets.only(top: 50, left: 50, right: 50) : const EdgeInsets.all(20),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 0.0),
                  child: Container(
                    margin: isNotMobile ? const EdgeInsets.only(top: 20, left: 50, right: 50) : const EdgeInsets.only(left: 10,top: 10),
                    child: ListView.builder(
                      itemCount: widget.beans == null
                          ? beans.length
                          : widget.beans.length,
                      itemBuilder: (ctx, index) {
                        final Object bean = widget.beans == null
                            ? beans[index]
                            : widget.beans[index];
                        final List<YearBean> yearBeans = widget.beans == null
                            ? beans[index].beans
                            : widget.beans[index].beans;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${widget.beans == null ? beans[index].year : widget.beans[index].tag}',
                              style: isNotMobile ? Theme.of(context).textTheme.headline4 : Theme.of(context).textTheme.headline6,
                            ),
                            Container(
                              margin: isNotMobile ? const EdgeInsets.only(top: 10, left: 50, right: 50) : EdgeInsets.all(0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    List.generate(yearBeans.length, (index2) {
                                  final yearBean = yearBeans[index2];
                                  return Container(
                                    margin: EdgeInsets.only(top: 8),
                                    child: isNotMobile ? ListTile(
                                      onTap: () {
                                        showWaitingDialog(context);
                                      },
                                      leading: Text(
                                        '${yearBean.articleName}',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'huawen_kt'),
                                      ),
                                      trailing: Text(
                                        '${getDate(DateTime.parse(yearBean.createTime))}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    ) : FlatButton(onPressed :() => showWaitingDialog(context), child: Text(
                                      '${yearBean.articleName}',
                                      style: TextStyle(
                                          fontSize: isNotMobile ? 20 : 15,
                                          fontFamily: 'huawen_kt'),
                                    ),),
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
    showDialog<dynamic>(
        context: context,
        builder: (ctx) {
          return const AlertDialog(
            content: Text('功能尚在开发中...'),
          );
        });
  }

  String getDate(DateTime time) {
    return '${time.year}.${time.month}.${time.day}';
  }
}
