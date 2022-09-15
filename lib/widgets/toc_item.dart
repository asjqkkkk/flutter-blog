import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:new_web/config/chinese_text.dart';
import 'package:new_web/theme/colors.dart';

class TocItemWidget extends StatelessWidget {
  const TocItemWidget(
      {Key? key,
      this.isCurrent = false,
      required this.toc,
      this.onTap,
      this.fontSize = 12.0})
      : super(key: key);

  final bool isCurrent;
  final Toc toc;
  final VoidCallback? onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return getNodeWidget(toc, context);
  }

  Widget getNodeWidget(Toc toc, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = toc.name;
    final level = toc.tagLevel;
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          border: Border(
              left: BorderSide(color: isCurrent ? color4 : Colors.grey))),
      padding: const EdgeInsets.only(left: 10),
      child: InkWell(
        child: Container(
          margin: EdgeInsets.fromLTRB(4.0 + 10 * level, 4, 4, 4),
          child: Text(
            name,
            style: isCurrent
                ? CTextStyle(
                    color: color4,
                    fontSize: fontSize,
                  )
                : CTextStyle(
                    fontSize: fontSize,
                    color: isDark ? Colors.grey : null,
                  ),
          ),
        ),
        onTap: () {
          if (!isCurrent) {
            onTap?.call();
          }
        },
      ),
    );
  }
}
