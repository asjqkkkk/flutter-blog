import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_web/json/one_line_json.dart';
import 'package:new_web/ui/empty_circle_shape.dart';
import 'package:new_web/widgets/all_widgets.dart';

import '../config/all_configs.dart';

class OneLineItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<OneLineData?>?>(
        valueListenable: GlobalData.instance.oneLineData,
        builder: (ctx, dynamic value, _) {
          if (value == null) return buildEmptyLayout();
          return _OneLineItems(lines: value);
        });
  }
}

class _OneLineItems extends StatefulWidget {
  const _OneLineItems({Key? key, required this.lines}) : super(key: key);
  final List<OneLineData> lines;

  @override
  _OneLineItemsState createState() => _OneLineItemsState();
}

class _OneLineItemsState extends State<_OneLineItems> {
  final _isFontLNotifier = ValueNotifier(false);
  final _switchController = SwitcherController();

  late _ShowItemModel _showItemModel;

  bool get isFront => _isFontLNotifier.value;

  List<OneLineData> get lines => widget.lines;

  List<OneLineData?> get showList => _showItemModel.showList;

  List<OneLineData>? get restList => _showItemModel.restList;

  Widget? fontWidget;
  Widget? backWidget;

  @override
  void initState() {
    _showItemModel = _ShowItemModel(lines);
    buildAllPages();
    super.initState();
  }

  void buildAllPages({bool isInitial = true}) {
    final one = showList[0];
    final two = showList[1];
    _showItemModel.changeList();
    final three = showList[0];
    final four = showList[1];
    fontWidget = buildPage(one, two);
    backWidget = buildPage(three, four, needReverse: true);
    if (isFront && !isInitial) {
      fontWidget = buildPage(three, four);
      backWidget = buildPage(one, two, needReverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: v400 * 2 + v240,
      margin:
          EdgeInsets.only(bottom: v64, top: v110, left: v76, right: v160 - v76),
      decoration: BoxDecoration(boxShadow: boxShadows),
      child: buildBody(),
    );
  }

  @override
  void dispose() {
    _switchController.dispose();
    super.dispose();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  Widget buildBody() {
    final buttonChild = buildRefreshButton(isLeft: !isFront);

    return Stack(
      fit: StackFit.expand,
      children: [
        ValueListenableBuilder(
            valueListenable: _isFontLNotifier,
            builder: (context, dynamic value, _) {
              return FlippableBox(
                isFlipped: isFront,
                front: fontWidget as Container?,
                back: backWidget as Container?,
                onEnd: () {
                  buildAllPages(isInitial: false);
                },
              );
            }),
        Center(
          child: CusInkWell(
            onTap: () {
              _isFontLNotifier.value = !isFront;
              _switchController
                  .changeWidget(() => buildRefreshButton(isLeft: !isFront));
            },
            child: CustomAnimatedSwitcher(
              child: buttonChild,
              duration: const Duration(milliseconds: 1000),
              switcherController: _switchController,
              enableFade: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPage(OneLineData? left, OneLineData? right,
      {bool needReverse = false}) {
    final firstColor = needReverse ? color14 : color15;
    final secondColor = needReverse ? color15 : color14;
    final firstTextColor = needReverse ? Colors.white : color16;
    final secondTextColor = needReverse ? color16 : Colors.white;
    return Container(
      width: v400 * 2 + v80,
      child: Row(
        children: [
          Expanded(
            child:
                buildHalfPage(firstColor, firstTextColor, left, isLeft: true),
          ),
          Expanded(
            child: buildHalfPage(secondColor, secondTextColor, right),
          ),
        ],
      ),
    );
  }

  Widget buildRefreshButton({bool isLeft = false}) {
    return HoverScaleWidget(
      scale: 0.8,
      child: Container(
        width: v76,
        height: v76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: boxShadows2,
        ),
        alignment: Alignment.center,
        child: Center(
          child: Transform.rotate(
            angle: isLeft ? 0 : pi,
            child: SvgPicture.asset(
              Svg.random,
              width: v32,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHalfPage(Color bgColor, Color textColor, OneLineData? oneLineData,
      {bool isLeft = false}) {
    final hasData = oneLineData != null;
    final boxPadding = isLeft
        ? EdgeInsets.only(bottom: v20, left: v20)
        : EdgeInsets.only(bottom: v20, right: v20);
    return CustomPaint(
      painter: EmptyCircleShape(
        isLeft: isLeft,
        emptyCircleRadius: v38,
        color: bgColor,
        borderRadius: v20,
      ),
      child: hasData
          ? Stack(children: [
              Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: v40, right: v40),
                  child: OneLineTypeItems(
                    oneLineData: oneLineData,
                    textColor: textColor,
                  )),
              Container(
                  alignment:
                      isLeft ? Alignment.bottomLeft : Alignment.bottomRight,
                  child: buildDateBox(textColor, oneLineData!.cardInfo!),
                  padding: boxPadding)
            ])
          : const SizedBox(),
    );
  }

  Widget buildDateBox(Color color, CardInfo cardInfo) {
    return IntrinsicWidth(
      child: Container(
        child: DottedBorder(
          color: color,
          strokeWidth: 0.5,
          strokeCap: StrokeCap.round,
          padding: EdgeInsets.zero,
          dashPattern: const [4, 4],
          radius: const Radius.circular(12),
          borderType: BorderType.RRect,
          child: Container(
            height: v60,
            padding: EdgeInsets.all(v10),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: v10,
                        color: color,
                      ),
                      SizedBox(width: v4),
                      Text(
                        _getTime(cardInfo.date!),
                        style: CTextStyle(color: color, fontSize: v12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: v10,
                        color: color,
                      ),
                      SizedBox(width: v4),
                      Text(
                        cardInfo.location!,
                        style: CTextStyle(color: color, fontSize: v12),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cloud,
                                size: v10,
                                color: color,
                              ),
                              SizedBox(width: v4),
                              Text(
                                cardInfo.weather!,
                                style: CTextStyle(color: color, fontSize: v12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShowItemModel {
  _ShowItemModel(this.initialList) {
    _changeList(initialList);
  }

  final List<OneLineData?> showList = [null, null];
  List<OneLineData>? restList;
  final List<OneLineData> initialList;

  void changeList() {
    _changeList(restList!, isInitial: false);
  }

  void _changeList(List<OneLineData> initialList, {bool isInitial = true}) {
    final list = getRandomNumList(initialList.length, 2);
    if (isInitial)
      restList = List.from(initialList);
    else {
      if (restList!.length <= 1) restList = List.from(this.initialList);
    }
    if (list.length == 1) {
      showList.removeAt(0);
      showList.add(restList!.removeAt(list[0]));
    } else if (list.length > 1) {
      showList.clear();
      final one = restList![list[0]];
      final two = restList![list[1]];
      showList.add(one);
      showList.add(two);
      restList!.remove(one);
      restList!.remove(two);
    }
  }
}

String _getTime(int time) {
  return _dataFormat.format(DateTime.fromMillisecondsSinceEpoch(time));
}

final _dataFormat = DateFormat('yyyy.MM.dd HH:mm');

List<int> getRandomNumList(int n, int m) {
  if (n <= 0 || m <= 0) return [];
  final list = List.generate(n + 1, (index) => index);
  if (m > n) return list;
  final List<int> result = [];
  int i = 0;
  while (i < m) {
    final num = n - i;
    final randomIndex = num > 0 ? Random().nextInt(num) : 0;
    result.add(list.removeAt(randomIndex));
    i++;
  }
  return result;
}
