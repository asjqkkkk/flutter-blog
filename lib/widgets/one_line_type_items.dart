import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/json/one_line_json.dart';

import 'basic_widgets/cus_inkwell.dart';

class OneLineTypeItems extends StatelessWidget {
  const OneLineTypeItems({
    Key? key,
    required this.oneLineData,
    required this.textColor,
  }) : super(key: key);

  final OneLineData? oneLineData;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  Widget buildBody() {
    Widget? result;
    switch (type) {
      case OneLineType.text:
        result = _TextItem(oneLineData: oneLineData, textColor: textColor);
        break;
      case OneLineType.poetry:
        result = PoetryItem(oneLineData: oneLineData, textColor: textColor);
        break;
      case OneLineType.internet:
        result = InternetItem(oneLineData: oneLineData, textColor: textColor);
        break;
    }
    return result;
  }

  OneLineType get type => oneLineData!.type;
}

class _TextItem extends StatelessWidget {
  const _TextItem({
    Key? key,
    required this.oneLineData,
    required this.textColor,
  }) : super(key: key);

  final OneLineData? oneLineData;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final hasTitle = oneLineData!.title?.isNotEmpty ?? false;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasTitle)
          Text(
            oneLineData!.title!,
            textAlign: TextAlign.center,
            style: CTextStyle(
                color: textColor,
                fontSize: v20,
                fontWeight: FontWeight.bold,
                height: 1),
          ),
        if (hasTitle) SizedBox(height: v16),
        Text(
          oneLineData!.content!,
          textAlign: TextAlign.center,
          style: CTextStyle(
            color: textColor,
            fontSize: v18,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class PoetryItem extends StatelessWidget {
  const PoetryItem({
    Key? key,
    required this.oneLineData,
    required this.textColor,
  }) : super(key: key);

  final OneLineData? oneLineData;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '《${oneLineData!.title}》',
          textAlign: TextAlign.center,
          style: CTextStyle(
              color: textColor,
              fontSize: v20,
              fontWeight: FontWeight.bold,
              height: 1),
        ),
        SizedBox(height: v16),
        Text(
          content!.author!,
          textAlign: TextAlign.center,
          style: CTextStyle(
            color: textColor,
            fontSize: v14,
            height: 1.25,
          ),
        ),
        SizedBox(height: v16),
        Text(
          oneLineData!.content!,
          textAlign: TextAlign.center,
          style: CTextStyle(
            color: textColor,
            fontSize: v18,
            height: 1.25,
          ),
        ),
        SizedBox(
          height: v16,
        ),
      ],
    );
  }

  PoetryItemContent? get content => oneLineData!.itemContent as PoetryItemContent?;
}

class InternetItem extends StatelessWidget {
  const InternetItem({
    Key? key,
    required this.oneLineData,
    required this.textColor,
  }) : super(key: key);

  final OneLineData? oneLineData;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          oneLineData!.content!,
          textAlign: TextAlign.center,
          style: CTextStyle(
            color: textColor,
            fontSize: v18,
            height: 1.25,
          ),
        ),
        SizedBox(
          height: v18,
        ),
        CusInkWell(
          child: Text(
            '—— ${content!.source}',
            style: CTextStyle(
                color: Colors.blueAccent,
                fontSize: v20,
                fontWeight: FontWeight.bold,
                height: 1),
          ),
          onTap: () {
            launch(content!.sourceLink!);
          },
        )
      ],
    );
  }

  InternetItemContent? get content =>
      oneLineData!.itemContent as InternetItemContent?;
}
