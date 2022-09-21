import 'package:flutter/material.dart';
import 'package:new_web/util/all_utils.dart';
import 'package:new_web/widgets/all_widgets.dart';

import '../config/all_configs.dart';

class WebBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final timeType = getTimeType();
    return Container(
      padding: EdgeInsets.only(top: v60),
      width: v400 * 2 + v240,
      child: Row(
        children: [
          SvgPicture.asset(
            _timeSvgMap[timeType]!,
            width: v49,
          ),
          SizedBox(width: v20),
          Text.rich(
            TextSpan(
                text: '${_timeMap[timeType]}好呀，',
                children: [
                  TextSpan(
                      text: '陌生人',
                      style: CTextStyle(color: color10, fontSize: v33)),
                ],
                style: CTextStyle(color: Colors.black, fontSize: v33)),
          ),
          const Expanded(
            child: SizedBox(),
          ),
          CusInkWell(
            onTap: () => showSearch(),
            child: Container(
              width: v383,
              height: v60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(v8), color: color11),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: v20),
                      child: Text(
                        '搜索文章',
                        style: CTextStyle(
                          fontSize: v18,
                          color: color12,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: v60,
                    height: v60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(v8), color: color4),
                    child: TextButton(
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(v8))),
                          padding: MaterialStateProperty.all(EdgeInsets.zero)),
                      onPressed: () => showSearch(),
                      child: HoverScaleWidget(
                        scale: 1.5,
                        child: Container(
                          width: v50,
                          height: v50,
                          padding: EdgeInsets.all(v12),
                          child: SvgPicture.asset(
                            Svg.search,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void showSearch() {
    FullScreenDialog.getInstance()!.showDialog(
      GlobalData.instance.context!,
      TopAnimationShowWidget(
        child: const SearchWidget(),
        distanceY: v100,
      ),
    );
  }

  TimeType getTimeType() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour <= 11 && hour >= 6) {
      return TimeType.morning;
    } else if (hour <= 14 && hour > 11) {
      return TimeType.midMoon;
    } else if (hour <= 19 && hour > 14) {
      return TimeType.afternoon;
    }
    return TimeType.night;
  }
}

const _timeMap = {
  TimeType.morning: '早上',
  TimeType.midMoon: '中午',
  TimeType.afternoon: '下午',
  TimeType.night: '晚上',
};

final _timeSvgMap = {
  TimeType.morning: Svg.morning,
  TimeType.midMoon: Svg.noon,
  TimeType.afternoon: Svg.morning,
  TimeType.night: Svg.night,
};

enum TimeType { morning, midMoon, afternoon, night }
