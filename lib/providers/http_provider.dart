import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dimiplan/constants/api_constants.dart';

class CacheEntry {
  CacheEntry({required this.data, required this.timestamp, required this.ttl});

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
    data: json['data'],
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    ttl: Duration(milliseconds: json['ttl']),
  );
  final String data;
  final DateTime timestamp;
  final Duration ttl;

  bool get isExpired => DateTime.now().isAfter(timestamp.add(ttl));

  Map<String, dynamic> toJson() => {
    'data': data,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'ttl': ttl.inMilliseconds,
  };
}

class HttpClient {
  final http.Client _client = http.Client();
  String? _sessionId;
  final Map<String, CacheEntry> _memoryCache = {};
  static const Duration _defaultCacheTtl = Duration(minutes: 5);

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

  // HTTP GET 요청 (캐싱 지원)
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    bool useCache = true,
    Duration? cacheTtl,
  }) async {
    // 캐시 확인
    if (useCache) {
      final cachedResponse = await _getCachedResponse(url.toString());
      if (cachedResponse != null) {
        return cachedResponse;
      }
    }

    final finalHeaders = await _getHeaders(headers);
    final response = await _client.get(url, headers: finalHeaders);

    // 성공적인 응답을 캐시에 저장
    if (useCache && response.statusCode == 200) {
      await _cacheResponse(
        url.toString(),
        response,
        cacheTtl ?? _defaultCacheTtl,
      );
    }

    return response;
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
      final url = Uri.https(ApiConstants.backendHost, ApiConstants.getUserPath);
      final response = await httpClient.get(url);

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      // TODO: 로깅 프레임워크로 교체
      debugPrint('세션 검증 중 오류: $e');
    }

    return false;
  }

  // 캐시된 응답 가져오기
  Future<http.Response?> _getCachedResponse(String key) async {
    // 메모리 캐시 확인
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      return http.Response(memoryEntry.data, 200);
    }

    // 만료된 메모리 캐시 항목 제거
    if (memoryEntry != null && memoryEntry.isExpired) {
      _memoryCache.remove(key);
    }

    // 디스크 캐시 확인
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'cache_$key';
      final cachedJson = prefs.getString(cacheKey);

      if (cachedJson != null) {
        final cacheEntry = CacheEntry.fromJson(json.decode(cachedJson));

        if (!cacheEntry.isExpired) {
          // 메모리 캐시에도 추가
          _memoryCache[key] = cacheEntry;
          return http.Response(cacheEntry.data, 200);
        } else {
          // 만료된 디스크 캐시 제거
          await prefs.remove(cacheKey);
        }
      }
    } catch (e) {
      // TODO: 로깅 프레임워크로 교체
      debugPrint('캐시 읽기 오류: $e');
    }

    return null;
  }

  // 응답을 캐시에 저장
  Future<void> _cacheResponse(
    String key,
    http.Response response,
    Duration ttl,
  ) async {
    final cacheEntry = CacheEntry(
      data: response.body,
      timestamp: DateTime.now(),
      ttl: ttl,
    );

    // 메모리 캐시에 저장
    _memoryCache[key] = cacheEntry;

    // 메모리 캐시 크기 제한 (최대 50개 항목)
    if (_memoryCache.length > 50) {
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
    }

    // 디스크 캐시에 저장
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'cache_$key';
      await prefs.setString(cacheKey, json.encode(cacheEntry.toJson()));
    } catch (e) {
      // TODO: 로깅 프레임워크로 교체
      debugPrint('캐시 저장 오류: $e');
    }
  }

  // 캐시 초기화
  Future<void> clearCache() async {
    _memoryCache.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('cache_'));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      // TODO: 로깅 프레임워크로 교체
      debugPrint('캐시 초기화 오류: $e');
    }
  }

  // 특정 키의 캐시 제거
  Future<void> removeCacheEntry(String key) async {
    _memoryCache.remove(key);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cache_$key');
    } catch (e) {
      // TODO: 로깅 프레임워크로 교체
      debugPrint('캐시 항목 제거 오류: $e');
    }
  }
}

// 전역 HTTP 클라이언트 인스턴스
final httpClient = HttpClient();
