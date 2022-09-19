import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:new_web/config/api_strategy.dart';
import 'package:new_web/config/path_config.dart';
import 'package:new_web/json/music_info.dart';
import 'package:new_web/json/ne_playlist_info.dart';
import 'package:path/path.dart' as p;

import 'file_util.dart';

class MusicInfoGenerator extends Generator {
  @override
  Future generatorJsonFile() async {
    final Response data = await ApiStrategy.getApiService()!
        .get('$NEMusicPlaylist?id=874911495')
        .single;
    final jsonPath = FileUtils().getJsonDir();
    if (!jsonPath.existsSync()) {
      jsonPath.createSync(recursive: true);
    }
    final musicJsonFile =
        File(p.join(jsonPath.path, '${PathConfig.music}.json'));
    if (!musicJsonFile.existsSync()) musicJsonFile.createSync();
    final info = await downloadMusics(data.body);
    musicJsonFile.writeAsStringSync(
        info.map((e) => jsonEncode(e.toJson())).toList().toString());
    print(
        '🎈:Json file has been created successfully!🎈 ------: ${musicJsonFile.path}');
  }

  Future<List<MusicInfo>> downloadMusics(String data) async {
    final current = Directory.current;
    final assetPath =
        Directory(p.join(current.path, PathConfig.assets, PathConfig.music));
    if (!assetPath.existsSync()) assetPath.createSync(recursive: true);
    final playListData = NePlaylistInfo.fromMap(jsonDecode(data));
    final tracks = playListData.result?.tracks ?? [];
    final List<MusicInfo> result = [];
    await Future.forEach<TracksBean>(tracks, (e) async {
      final id = e.id.toString();
      final playUrl = NEMusicPlayUrl + e.id.toString();
      final pic = e.album!.picUrl!;
      final picName = p.basename(pic);
      final musicFile = File(p.join(assetPath.path, '$id.mp3'));
      final picFile = File(p.join(assetPath.path, picName));
      final musicInfo = MusicInfo(
          author: e.artists!.map((artist) => artist.name).join().trim(),
          picUrl: FileUtils().getAssetFile(picFile.path),
          playUrl: FileUtils().getAssetFile(musicFile.path),
          title: e.name);
      if (!musicFile.existsSync()) {
        final Response data =
            await ApiStrategy.getApiService()!.get(playUrl).single;
        musicFile.writeAsBytesSync(data.bodyBytes);
        print('🎈 ${e.name} donwload complete!🎈');
      }
      if (!picFile.existsSync()) {
        final Response data = await ApiStrategy.getApiService()!.get(pic).single;
        picFile.writeAsBytesSync(data.bodyBytes);
      }
      result.add(musicInfo);
    });
    return result;
  }
}

void main() {
  test('测试生成Music数据json', () async {
    await MusicInfoGenerator().generatorJsonFile();
  });
}
