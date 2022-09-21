import 'package:flutter_test/flutter_test.dart';

import 'utils/article_generator.dart';
import 'utils/canvaskit_generator.dart';
import 'utils/chinese_generator.dart';
import 'utils/file_util.dart';
import 'utils/friend_info_generator.dart';
import 'utils/game_screen_generator.dart';
// import 'utils/music_info_generator.dart';
import 'utils/one_line_generator.dart';

void main() {
  test('生成文件', () async {
    final List<Generator> generators = [
      GameScreenGenerator(),
      // MusicInfoGenerator(),
      FriendGenerator(),
      ArticleGenerator(),
      ChineseGenerator(),
      OneLineGenerator(),
    ];
    await Future.forEach<Generator>(
      generators,
      (element) async => await element.generatorJsonFile(),
    );
    await FileUtils().autoDeclareAssetPath();
  });
}

///运行命令，编译文件：flutter test test/generator.dart
