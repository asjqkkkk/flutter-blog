import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:new_web/config/api_strategy.dart';
import 'package:new_web/config/path_config.dart';
import 'package:new_web/json/friend_link.dart';
import 'package:path/path.dart' as p;

import 'file_util.dart';

class FriendGenerator extends Generator {
  @override
  Future generatorJsonFile() async {
    final jsonPath = FileUtils().getJsonDir();
    if (!jsonPath.existsSync()) {
      jsonPath.createSync(recursive: true);
    }
    final jsonFile = File(p.join(jsonPath.path, '${PathConfig.friend}.json'));
    final List<FriendLinkBean?> beans = [];
    if (!jsonFile.existsSync()) {
      beans.addAll(_beans);
    } else {
      final value =
          FriendLinkBean.fromMapList(jsonDecode(jsonFile.readAsStringSync()));
      beans.addAll(value);
    }
    final info = await downloadInfo(beans);
    if (!jsonFile.existsSync()) jsonFile.createSync();
    jsonFile.writeAsStringSync(
        info.map((e) => jsonEncode(e!.toJson())).toList().toString());
    print(
        '🎈:Json file has been created successfully!🎈 ------: ${jsonFile.path}');
  }

  Future<List<FriendLinkBean?>> downloadInfo(List<FriendLinkBean?> beans) async {
    final current = Directory.current;
    final assetPath =
        Directory(p.join(current.path, PathConfig.assets, PathConfig.friend));
    if (!assetPath.existsSync()) assetPath.createSync(recursive: true);
    await Future.forEach<FriendLinkBean?>(beans, (e) async {
      final playUrl = e!.linkAvatar!;
      if (e.id == null || e.id!.isEmpty)
        e.id = DateTime.now().millisecondsSinceEpoch.toString();
      final picName = e.id! + '.png';
      final picFile = File(p.join(assetPath.path, picName));
      bool hasFile = true;
      if (!picFile.existsSync()) {
        picFile.createSync();
        hasFile = false;
      }
      final Response data =
          await ApiStrategy.getApiService()!.get(playUrl).single;
      picFile.writeAsBytesSync(data.bodyBytes);
      e.assetAvatar = FileUtils().getAssetFile(picFile.path);
      print(
          '🎈 ${e.linkName} avatar ${hasFile ? 'update' : 'download'} complete!🎈');
    });
    return beans;
  }
}

void main() {
  test('测试生成友链数据json', () async {
    await FriendGenerator().generatorJsonFile();
  });
}

final List<FriendLinkBean> _beans = [
  FriendLinkBean(
    linkName: '冷石的博客',
    linkAddress: 'https://coldstone.fun/',
    profession: '程序员',
    linkAvatar: 'https://avatars2.githubusercontent.com/u/18013127?s=460&v=4',
  ),
  FriendLinkBean(
    linkName: 'ColMugX的博客',
    linkAddress: 'https://colmugx.github.io/',
    profession: '程序员',
    linkAvatar: 'https://avatars2.githubusercontent.com/u/21327913?s=460&v=4',
  ),
  FriendLinkBean(
    linkName: '公瑾的博客',
    linkAddress: 'https://www.yuque.com/levy/blog',
    profession: '技术经理',
    linkAvatar: 'https://avatars3.githubusercontent.com/u/9384365?s=460&v=4',
  ),
  FriendLinkBean(
      linkName: 'senfang的博客',
      linkAddress: 'https://senfangblog.cn/',
      profession: '程序员',
      linkAvatar:
          'https://oldchen-blog-1256696029.cos.ap-guangzhou.myqcloud.com/senfangblog.jpeg'),
  FriendLinkBean(
      linkName: 'EVILLT的博客',
      linkAddress: 'https://evila.me/#/',
      profession: '程序员',
      linkAvatar:
          'https://avatars2.githubusercontent.com/u/19513289?s=460&v=4'),
  FriendLinkBean(
      linkName: '老涛子的博客',
      linkAddress: 'http://www.sporoka.com/',
      profession: '程序员',
      linkAvatar:
          'https://oldchen-blog-1256696029.cos.ap-guangzhou.myqcloud.com/old_tao.jpg'),
];
