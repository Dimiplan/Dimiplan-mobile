import 'dart:convert';
import 'package:dimiplan/providers/http_provider.dart';
import 'package:dimiplan/constants/api_constants.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ApiUtils {
  static Future<T?> performApiCall<T>({
    required Future<T> Function() apiCall,
    String? errorMessage,
    bool shouldValidateSession = true,
  }) async {
    try {
      if (shouldValidateSession) {
        final isSessionValid = await httpClient.isSessionValid();
        if (!isSessionValid) {
          return null;
        }
      }

      return await apiCall();
    } catch (e) {
      logger.e('${errorMessage ?? 'API 호출'} 중 오류 발생', error: e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> fetchData(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    return performApiCall<Map<String, dynamic>?>(
      apiCall: () async {
        final url = Uri.https(ApiConstants.backendHost, path, queryParams);
        final response = await httpClient.get(url);

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('HTTP ${response.statusCode}: ${response.body}');
        }
      },
      errorMessage: '데이터 가져오기',
    );
  }

  static Future<Map<String, dynamic>?> postData(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    return performApiCall<Map<String, dynamic>?>(
      apiCall: () async {
        final url = Uri.https(ApiConstants.backendHost, path);
        final response = await httpClient.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return json.decode(response.body);
        } else {
          throw Exception('HTTP ${response.statusCode}: ${response.body}');
        }
      },
      errorMessage: '데이터 전송',
    );
  }

  static Future<Map<String, dynamic>?> patchData(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    return performApiCall<Map<String, dynamic>?>(
      apiCall: () async {
        final url = Uri.https(ApiConstants.backendHost, path);
        final response = await httpClient.patch(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('HTTP ${response.statusCode}: ${response.body}');
        }
      },
      errorMessage: '데이터 수정',
    );
  }

  static Future<Map<String, dynamic>?> deleteData(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    return performApiCall<Map<String, dynamic>?>(
      apiCall: () async {
        final url = Uri.https(ApiConstants.backendHost, path);
        final response = await httpClient.delete(
          url,
          headers: {'Content-Type': 'application/json'},
          body: data != null ? json.encode(data) : null,
        );

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('HTTP ${response.statusCode}: ${response.body}');
        }
      },
      errorMessage: '데이터 삭제',
    );
  }

  static Uri buildApiUrl(String path, [Map<String, String>? queryParams]) {
    return Uri.https(ApiConstants.backendHost, path, queryParams);
  }
}
