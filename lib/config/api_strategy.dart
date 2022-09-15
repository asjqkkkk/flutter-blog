import 'package:http/http.dart' as http;
export 'urls.dart';

class ApiStrategy {
  ApiStrategy._internal() {
    final client = http.Client();
    _service = ApiService(client);
  }

  static ApiService? _service;

  static ApiService? getApiService() {
    if (_service == null) ApiStrategy._internal();
    return _service;
  }

  ///baseUrl
  // static String baseUrl = Config.baseUrl;

  //读超时长，单位：毫秒
  static const int READ_TIME_OUT = 3 * 1000;

  //连接时长，单位：毫秒
  static const int CONNECT_TIME_OUT = 3 * 1000;
}

class ApiService {
  ApiService(this._client);

  final http.Client _client;

  ///get请求
  Future _get(
    String url, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
  }) async {
    final queryString = Uri(queryParameters: queryParams ?? {}).query;
    final queryUrl = queryString.isEmpty ? '' : '?$queryString';
    final response =
        await _client.get(Uri.parse(url + queryUrl), headers: headers as Map<String, String>?);
    return response;
  }

  //
  // ///post请求
  // Future<T> _post<T>(
  //   String url,
  //   Map<String, dynamic> params, {
  //   Map<String, dynamic> headers,
  //   Map<String, dynamic> queryParams,
  //   CancelToken cancelToken,
  // }) async {
  //   _putHeader(_client, headers);
  //   final Response response = await _client.post<T>(
  //     url,
  //     data: params,
  //     queryParameters: queryParams,
  //     cancelToken: cancelToken,
  //   );
  //   return response.data;
  // }
  //
  // ///put请求
  // Future<T> _put<T>(
  //   String url,
  //   Map<String, dynamic> params, {
  //   Map<String, dynamic> headers,
  //   Map<String, dynamic> queryParams,
  //   CancelToken cancelToken,
  // }) async {
  //   _putHeader(_client, headers);
  //   final Response response = await _client.put<T>(
  //     url,
  //     queryParameters: queryParams,
  //     cancelToken: cancelToken,
  //     data: params,
  //   );
  //   return response.data;
  // }
  //
  //
  // Stream<T> post<T>(
  //   String url,
  //   Map<String, dynamic> params, {
  //   Map<String, dynamic> headers,
  //   Map<String, dynamic> queryParams,
  //   CancelToken cancelToken,
  // }) =>
  //     Stream<T>.fromFuture(_post(
  //       url,
  //       params,
  //       headers: headers,
  //       cancelToken: cancelToken,
  //       queryParams: queryParams,
  //     )).asBroadcastStream();

  Stream get(
    String url, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) =>
      Stream.fromFuture(_get(url, queryParams: params, headers: headers))
          .asBroadcastStream();

// Stream<T> put<T>(
//   String url,
//   Map<String, dynamic> params, {
//   Map<String, dynamic> headers,
//   Map<String, dynamic> queryParams,
//   CancelToken cancelToken,
// }) =>
//     Stream<T>.fromFuture(_put(
//       url,
//       params,
//       headers: headers,
//       cancelToken: cancelToken,
//       queryParams: queryParams,
//     )).asBroadcastStream();
}
