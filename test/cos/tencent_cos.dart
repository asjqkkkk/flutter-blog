import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../lib/dio.dart';

class TencentCos {
  static bool debug = true;

  /// auth signature expired time in seconds
  static final int signExpireTimeInSeconds = 1000;

  static final String secretId = 'AKIDFJC7sNhbLp30pObkX5SnuxkHcgZCGebI';
  static final String secretKey = 'auxoTs2C6k9JEtNcibGhtsc6NWR6VfZE';
  static final String bucketHost =
      'oldchen-blog-1256696029.cos.ap-guangzhou.myqcloud.com';

  static TencentCos _cos;

  TencentCos._();

  static TencentCos get() {
    if (_cos == null) {
      _cos = TencentCos._();
    }

    return _cos;
  }

  String _getKeyTime() {
    final now = DateTime.now();
    final end =
        DateTime(now.year, now.month, now.day, now.hour + 1, now.minute);
    final startUnixTimestamp = now.millisecondsSinceEpoch ~/ 1000;
    final endUnixTimestamp = end.millisecondsSinceEpoch ~/ 1000;
    return '$startUnixTimestamp;$endUnixTimestamp';
  }

  String _getSignKey(String secretKey, String keyTime) {
    final key = utf8.encode(secretKey);
    final bytes = utf8.encode(keyTime);

    final hMacSha1 = new Hmac(sha1, key);
    final digest = hMacSha1.convert(bytes);
    return digest.toString();
  }

  Future<Response> putObject(String bucketPath) async {
    final current = Directory.current;
    File file =
        File(p.join(current.path, 'assets', 'config', 'config_study.json'));

    final url = 'https://$bucketHost';
    final filePath = '$bucketPath${p.basename(file.path)}';

    Dio dio = new Dio();
    dio.interceptors.add(LogInterceptor(
        requestBody: true, responseBody: true, requestHeader: true));
    final data =
        FormData.fromMap({'file': await MultipartFile.fromFile(file.path)});
    final response = await dio.put(url + filePath,
        data: data,
        options: Options(
          headers: _buildHeaders(filePath),
        ));

    return response;
  }

  Map<String, String> _buildHeaders(String url) {
    Map<String, String> headers = Map();
//    headers['HOST'] = bucketHost;
    headers['Authorization'] = _auth('put', url);
//    if (debug) {
//      print(headers);
//    }
    return headers;
  }

  String _auth(
    String httpMethod,
    String httpUrl,
  ) {
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var keyTime =
        '$currentTimestamp;${currentTimestamp + signExpireTimeInSeconds}';
    print('KeyTime:$keyTime');


    var signKey =
        new Hmac(sha1, utf8.encode(secretKey)).convert(utf8.encode(keyTime));
    print('SignKey:$signKey');

    String httpString = '${httpMethod.toLowerCase()}\n$httpUrl\n\n\n';
    print('HttpString:$httpString');

    var httpStringData = sha1.convert(utf8.encode(httpString));
    var stringToSign = 'sha1\n$keyTime\n$httpStringData\n';
    print('StringToSign:$stringToSign');

    var signature = new Hmac(sha1, utf8.encode(signKey.toString()))
        .convert(utf8.encode(stringToSign));
    print('Signature:$signature');

    String auth =
        'q-sign-algorithm=sha1&q-ak=$secretId&q-sign-time=$keyTime&q-key-time=$keyTime&q-header-list=&q-url-param-list=&q-signature=$signature'
            .trim();
    return auth;
  }
}
