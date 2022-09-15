import 'package:flutter/material.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/items/about_item.dart';

import 'basic_widgets/cus_inkwell.dart';

class GameTypeItem extends StatelessWidget {
  const GameTypeItem({Key? key, required this.gameItem}) : super(key: key);

  final GameItem gameItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(v68, v60, v68, v40),
      child: Row(
        children: [
          Expanded(child: _CommonWidget(gameItem: gameItem)),
          Expanded(child: SvgPicture.asset(gameItem.bgPath)),
        ],
      ),
    );
  }
}

class _CommonWidget extends StatelessWidget {
  const _CommonWidget({
    Key? key,
    required this.gameItem,
  }) : super(key: key);

  final GameItem gameItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gameItem.title,
          style: CTextStyle(
            fontSize: v42,
            height: 1,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: v18,
        ),
        Text(
          gameItem.description,
          style: CTextStyle(
            fontSize: v20,
            height: 1.25,
            color: Colors.white,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(
          height: v24,
        ),
        if (gameItem.link != null)
          CusInkWell(
            onTap: () {
              launch(gameItem.link!);
            },
            child: Container(
              width: v112,
              height: v43,
              decoration: BoxDecoration(
                color: gameItem.colors[1],
                borderRadius: BorderRadius.circular(v8),
              ),
              child: Center(
                  child: Text(
                gameItem.linkDes,
                style: CTextStyle(
                  color: Colors.white,
                  fontSize: v16,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ),
          ),
      ],
    );
  }
}
