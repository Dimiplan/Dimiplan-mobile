import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dimiplan/providers/http_provider.dart';
import 'package:dimiplan/models/user_model.dart';
import 'package:dimiplan/constants/api_constants.dart';
import 'package:dimiplan/utils/state_utils.dart';
import 'package:dimiplan/utils/api_utils.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AuthProvider extends ChangeNotifier with LoadingStateMixin {
  User? _user;
  bool _isAuthenticated = false;
  int _taskCount = 0;

  // 게터
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  int get taskCount => _taskCount;
  bool get isDimigoStudent => _user?.email.endsWith('@dimigo.hs.kr') ?? false;

  /// 인증 상태 확인
  Future<void> checkAuth() async {
    await AsyncOperationHandler.execute(
      operation: () async {
        final isValid = await httpClient.isSessionValid();

        if (!isValid) {
          _setAuthenticated(false);
          return;
        }

        await _fetchUserInfo();
        await _fetchTaskCount();
      },
      setLoading: setLoading,
      onError: (_) => _setAuthenticated(false),
      errorContext: '인증 확인',
    );
  }

  /// 사용자 정보 가져오기
  Future<void> _fetchUserInfo() async {
    try {
      final userData = await ApiUtils.fetchData(ApiConstants.user.get);
      if (userData != null) {
        _user = User.fromMap(userData);
        _setAuthenticated(true);
        await _checkUserRegistered();
      } else {
        await _clearSession();
        _setAuthenticated(false);
      }
    } catch (e) {
      logger.e('사용자 정보 가져오기 실패', error: e);
      _setAuthenticated(false);
    }
  }

  /// 유저 등록 상태 확인
  Future<void> _checkUserRegistered() async {
    try {
      final url = Uri.https(
        ApiConstants.backendHost,
        ApiConstants.user.registered,
      );
      final response = await httpClient.get(url);

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
      final data = await ApiUtils.fetchData(ApiConstants.task.get);
      if (data != null && data is List) {
        _updateTaskCount(data.length);
      }
    } catch (e) {
      logger.e('작업 수 가져오기 실패', error: e);
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
    await AsyncOperationHandler.execute(
      operation: () async {
        final GoogleSignInAccount? googleUser =
            await GoogleSignIn().signInSilently() ??
            await GoogleSignIn().signIn();

        final body = {
          'userId': googleUser?.id,
          'email': googleUser?.email,
          'photo': googleUser?.photoUrl,
          'name': googleUser?.displayName,
        };

        final url = ApiUtils.buildApiUrl(ApiConstants.auth.login);
        final response = await httpClient.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        );

        if (response.statusCode == 200) {
          final String? sessionId = response.headers['x-session-id'];

          if (sessionId != null) {
            await httpClient.setSessionId(sessionId);
          } else {
            throw Exception('세션 ID를 받을 수 없습니다.');
          }
          await _fetchUserInfo();
          await _fetchTaskCount();
        } else {
          throw Exception('로그인 실패: ${response.statusCode}, ${response.body}');
        }
      },
      setLoading: setLoading,
      onError: (_) => _setAuthenticated(false),
      errorContext: '로그인',
    );
  }

  /// 로그아웃
  Future<void> logout() async {
    await AsyncOperationHandler.execute(
      operation: () async {
        await GoogleSignIn().signOut();
        await _clearSession();
        _setAuthenticated(false);
        _user = null;
      },
      setLoading: setLoading,
      errorContext: '로그아웃',
    );
  }

  /// 세션 초기화
  Future<void> _clearSession() async {
    await httpClient.clearSessionId();
  }

  /// 사용자 정보 업데이트
  Future<void> updateUser(Map<String, dynamic> userData) async {
    await AsyncOperationHandler.execute(
      operation: () async {
        await ApiUtils.postData(ApiConstants.user.update, data: userData);
        await refreshUserInfo();
      },
      setLoading: setLoading,
      errorContext: '사용자 정보 업데이트',
    );
  }

  /// 사용자 정보 새로고침
  Future<void> refreshUserInfo() async {
    await _fetchUserInfo();
    safeNotifyListeners();
  }

  /// 인증 상태 설정
  void _setAuthenticated(bool authenticated) {
    if (_isAuthenticated != authenticated) {
      _isAuthenticated = authenticated;
      safeNotifyListeners();
    }
  }
}
