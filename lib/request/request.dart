import 'package:dio/dio.dart';

class RequestManager {
  late final Dio _dio;

  static RequestManager? _instance;

  RequestManager._initManager() {
    BaseOptions baseOptions = BaseOptions(
      connectTimeout: const Duration(milliseconds: 150000),
      receiveTimeout: const Duration(milliseconds: 5000),
      baseUrl: 'http://156.245.145.81:14949',
    );
    _dio = Dio(baseOptions);

    // 添加拦截器
    _dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false, error: true));
    _dio.interceptors.add(Interceptors());
  }

  factory RequestManager() {
    _instance ??= RequestManager._initManager();
    return _instance!;
  }

  Future<Response> handleRequest(String path, String method, {data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final merged = (options ?? Options()).copyWith(method: method);
      return await _dio.request(path, data: data, queryParameters: queryParameters, options: merged);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection Timeout! Please check your network.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive Timeout! Server may not be responding.');
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception('Server Error: ${e.response?.statusCode} -> ${e.response?.data}');
      } else if (e.type == DioExceptionType.unknown) {
        throw Exception('Network Error: ${e.message}');
      } else {
        throw Exception('Unexpected error: ${e.message}');
      }
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return handleRequest(path, 'GET', queryParameters: queryParameters);
  }

  Future<Response> post(String path, {data, Map<String, dynamic>? queryParameters}) {
    return handleRequest(path, 'POST', data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {data, Map<String, dynamic>? queryParameters}) {
    return handleRequest(path, 'PUT', data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) {
    return handleRequest(path, 'DELETE', queryParameters: queryParameters);
  }
}

/// 自定义拦截器
class Interceptors extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // final Map? userInfo = await userInfoGettingCache();
    // final authorization = userInfo!.isNotEmpty ? 'Bearer ${userInfo['token']}' : '';
    // options.headers.addAll({'Authorization': authorization, 'source-client': 'app'});
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      handler.reject(
        DioException(requestOptions: err.requestOptions, response: err.response, type: DioExceptionType.badResponse, error: 'unauthorized'),
      );
    } else {
      super.onError(err, handler);
    }
  }
}
