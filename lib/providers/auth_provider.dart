import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http_cookie_store/http_cookie_store.dart';
import 'package:dimiplan/providers/http_provider.dart';
import 'package:collection/collection.dart';
import 'package:dimiplan/models/user_model.dart';
import 'package:dimiplan/constants/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  int _taskCount = 0;

  // 게터
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  int get taskCount => _taskCount;
  bool get isDimigoStudent => _user?.email.endsWith('@dimigo.hs.kr') ?? false;

  /// 인증 상태 확인
  Future<void> checkAuth() async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final session =
          http.store[CookieKey(
            'dimiplan.sid',
            Uri.https(ApiConstants.backendHost),
          )];
      if (session == null || session.value.isEmpty) {
        _setAuthenticated(false);
        _setLoading(false);
        return;
      }

      // 세션 유효성 및 사용자 정보 확인
      await _fetchUserInfo();
      await _fetchTaskCount();
    } catch (e) {
      print('인증 확인 중 오류 발생: $e');
      _setAuthenticated(false);
    } finally {
      _setLoading(false);
    }
  }

  /// 사용자 정보 가져오기
  Future<void> _fetchUserInfo() async {
    try {
      final session =
          http.store[CookieKey(
            'dimiplan.sid',
            Uri.https(ApiConstants.backendHost),
          )];
      if (session == null || session.value.isEmpty) {
        _setAuthenticated(false);
        return;
      }

      final url = Uri.https(ApiConstants.backendHost, ApiConstants.whoamiPath);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        _user = User.fromMap(userData);
        _setAuthenticated(true);

        // 사용자 등록 상태 확인
        await _checkUserRegistered();
      } else {
        // 세션이 유효하지 않음
        await _clearSession();
        _setAuthenticated(false);
      }
    } catch (e) {
      print('사용자 정보 가져오기 실패: $e');
      _setAuthenticated(false);
    }
  }

  /// 유저 등록 상태 확인
  Future<void> _checkUserRegistered() async {
    try {
      final session =
          http.store[CookieKey(
            'dimiplan.sid',
            Uri.https(ApiConstants.backendHost),
          )];
      if (session == null || session.value.isEmpty) return;

      final url = Uri.https(
        ApiConstants.backendHost,
        ApiConstants.registeredPath,
      );
      final response = await http.get(url);

      if (response.statusCode != 200) {
        // 등록되지 않은 사용자는 프로필 수정 화면으로 이동해야 함
        // 이 부분은 UI 측에서 처리
      }
    } catch (e) {
      print('사용자 등록 상태 확인 실패: $e');
    }
  }

  /// 작업 수 가져오기
  Future<void> _fetchTaskCount() async {
    try {
      final session =
          http.store[CookieKey(
            'dimiplan.sid',
            Uri.https(ApiConstants.backendHost),
          )];
      if (session == null || session.value.isEmpty) return;

      final url = Uri.https(ApiConstants.backendHost, '/api/plan/getEveryPlan');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _updateTaskCount(data.length);
      }
    } catch (e) {
      print('작업 수 가져오기 실패: $e');
    }
  }

  /// 작업 수 업데이트 (내부 사용)
  void _updateTaskCount(int count) {
    if (_taskCount != count) {
      _taskCount = count;
      // Use Future.microtask to avoid calling notifyListeners during build
      Future.microtask(() => notifyListeners());
    }
  }

  /// 로그인
  Future<void> login() async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      // 구글 로그인 시작
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn().signInSilently() ??
          await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw Exception('로그인이 취소되었습니다.');
      }

      // 서버에 로그인 요청
      final url = Uri.https(ApiConstants.backendHost, '/auth/login');
      final body = {
        'userId': googleUser.id,
        'email': googleUser.email,
        'photo': googleUser.photoUrl,
        'name': googleUser.displayName,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final session =
            http.store[CookieKey(
              'dimiplan.sid',
              Uri.https(ApiConstants.backendHost),
            )];
        groupBy(http.store.cookies, (c) => c.domain).forEach((key, value) {
          print("$key:");
          for (var cookie in value) {
            print('\t$cookie');
          }
        });
        if (session != null && session.value.isNotEmpty) {
          await _fetchUserInfo();
          await _fetchTaskCount();
        } else {
          throw Exception('유효하지 않은 세션 ID');
        }
      } else {
        throw Exception('로그인 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('로그인 중 오류 발생: $e');
      _setAuthenticated(false);
      rethrow; // 호출자에게 오류 전달
    } finally {
      _setLoading(false);
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      await GoogleSignIn().signOut();
      await _clearSession();
      _setAuthenticated(false);
      _user = null;
    } catch (e) {
      print('로그아웃 중 오류 발생: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 세션 초기화
  Future<void> _clearSession() async {
    http.store.clear();
  }

  /// 사용자 정보 업데이트
  Future<void> updateUser(Map<String, dynamic> userData) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      final session =
          http.store[CookieKey(
            'dimiplan.sid',
            Uri.https(ApiConstants.backendHost),
          )];
      if (session == null || session.value.isEmpty) {
        throw Exception('로그인이 필요합니다.');
      }

      final url = Uri.https(ApiConstants.backendHost, '/api/user/updateme');
      final response = await http.post(
        url,
        headers: {
          'Cookie': "dimigo.sid=$session",
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        // 성공적으로 업데이트됨, 사용자 정보 새로고침
        await refreshUserInfo();
      } else {
        throw Exception('사용자 정보 업데이트 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('사용자 정보 업데이트 중 오류 발생: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// 사용자 정보 새로고침
  Future<void> refreshUserInfo() async {
    await _fetchUserInfo();
    // Use Future.microtask to avoid calling notifyListeners during build
    Future.microtask(() => notifyListeners());
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      // Use Future.microtask to avoid calling notifyListeners during build
      Future.microtask(() => notifyListeners());
    }
  }

  /// 인증 상태 설정
  void _setAuthenticated(bool authenticated) {
    if (_isAuthenticated != authenticated) {
      _isAuthenticated = authenticated;
      // Use Future.microtask to avoid calling notifyListeners during build
      Future.microtask(() => notifyListeners());
    }
  }
}
