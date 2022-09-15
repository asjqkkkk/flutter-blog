import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:new_web/config/api_strategy.dart';
import 'package:new_web/config/path_config.dart';
import 'package:new_web/json/one_line_json.dart';
import 'package:path/path.dart' as p;

import 'file_util.dart';

void main() {
  test('信息获取', () async {
    final generator = OneLineGenerator();
    await generator.generatorJsonFile();
  });
}

class OneLineGenerator extends Generator {
  Future<Location> getLocation() async {
    final Response data = await (ApiStrategy.getApiService()!
        .get('http://ip-api.com/json/?lang=zh-CN')
        .single as FutureOr<Response>);
    return Location.fromMap(jsonDecode(data.body));
  }

  Future<String?> getWeather(String location) async {
    final Response data = await (ApiStrategy.getApiService()!
        .get(
            'https://devapi.qweather.com/v7/weather/now?location=$location&key=d381a4276ed349daa3bf63646f12d8ae')
        .single as FutureOr<Response>);
    return jsonDecode(data.body)['now']['text'];
  }

  Future<CardInfo> buildCardInfo() async {
    final time = DateTime.now().millisecondsSinceEpoch;
    final location = await getLocation();
    final weather = await getWeather('${location.lon},${location.lat}');
    return CardInfo(
      weather: weather,
      location: '${location.regionName} ${location.city}',
      date: time,
      ipAddress: location.query,
    );
  }

  @override
  Future generatorJsonFile() async {
    final jsonDir = FileUtils().getJsonDir();
    final card = await buildCardInfo();
    final jsonFile =
        File(p.join(jsonDir.path, '${PathConfig.oneLinePath}.json'));
    if (!jsonFile.existsSync()) jsonFile.createSync();
    final jsonData = jsonDecode(jsonFile.readAsStringSync());
    final items = OneLineData.fromMapList(jsonData);
    items.forEach((element) {
      element.cardInfo ??= card;
    });
    jsonFile.writeAsStringSync(
      items.map((e) => jsonEncode(e.toJson())).toList().toString(),
    );
    print(
        '🎈:Json file has been created successfully!🎈 ------: ${jsonFile.path}');
  }
}

/// status : "success"
/// country : "�й�"
/// countryCode : "CN"
/// region : "GD"
/// regionName : "�㶫"
/// city : "������"
/// zip : ""
/// lat : 22.5333
/// lon : 114.1333
/// timezone : "Asia/Shanghai"
/// isp : "Chinanet"
/// org : "Chinanet GD"
/// as : "AS4134 CHINANET-BACKBONE"
/// query : "119.123.197.99"

class Location {
  Location.fromMap(Map<String, dynamic> map) {
    status = map['status'];
    country = map['country'];
    countryCode = map['countryCode'];
    region = map['region'];
    regionName = map['regionName'];
    city = map['city'];
    zip = map['zip'];
    lat = map['lat'];
    lon = map['lon'];
    timezone = map['timezone'];
    isp = map['isp'];
    org = map['org'];
    as = map['as'];
    query = map['query'];
  }

  String? status;
  String? country;
  String? countryCode;
  String? region;
  String? regionName;
  String? city;
  String? zip;
  double? lat;
  double? lon;
  String? timezone;
  String? isp;
  String? org;
  String? as;
  String? query;

  Map toJson() => {
        'status': status,
        'country': country,
        'countryCode': countryCode,
        'region': region,
        'regionName': regionName,
        'city': city,
        'zip': zip,
        'lat': lat,
        'lon': lon,
        'timezone': timezone,
        'isp': isp,
        'org': org,
        'as': as,
        'query': query,
      };
}
