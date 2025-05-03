import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dimiplan/constants/api_constants.dart';
import 'dart:convert';

class HttpClient {
  final http.Client _client = http.Client();
  String? _sessionId;

  // 세션 ID 가져오기
  Future<String?> get sessionId async {
    if (_sessionId == null) {
      final prefs = await SharedPreferences.getInstance();
      _sessionId = prefs.getString('session_id');
    }
    return _sessionId;
  }

  // 세션 ID 저장
  Future<void> setSessionId(String sessionId) async {
    _sessionId = sessionId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_id', sessionId);
  }

  // 세션 ID 초기화
  Future<void> clearSessionId() async {
    _sessionId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_id');
  }

  // 세션 ID를 헤더에 추가
  Future<Map<String, String>> _getHeaders(Map<String, String>? headers) async {
    final result = Map<String, String>.from(headers ?? {});
    final sid = await sessionId;
    if (sid != null) {
      // 모든 헤더 이름을 소문자로 사용
      result['x-session-id'] = sid;
    }
    return result;
  }

  // HTTP GET 요청
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final finalHeaders = await _getHeaders(headers);
    return _client.get(url, headers: finalHeaders);
  }

  // HTTP POST 요청
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final finalHeaders = await _getHeaders(headers);
    return _client.post(url, headers: finalHeaders, body: body);
  }

  // HTTP PUT 요청
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final finalHeaders = await _getHeaders(headers);
    return _client.put(url, headers: finalHeaders, body: body);
  }

  // HTTP DELETE 요청
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final finalHeaders = await _getHeaders(headers);
    return _client.delete(url, headers: finalHeaders, body: body);
  }

  // 세션 유효성 검사
  Future<bool> isSessionValid() async {
    final sid = await sessionId;
    if (sid == null) return false;

    try {
      final url = Uri.https(ApiConstants.backendHost, '/auth/session');
      final response = await get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['valid'] == true;
      }
    } catch (e) {
      print('세션 검증 중 오류: $e');
    }

    return false;
  }
}

// 전역 HTTP 클라이언트 인스턴스
final Http = HttpClient();
