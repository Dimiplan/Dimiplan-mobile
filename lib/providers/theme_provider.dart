import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dimiplan/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'dimiplan_dark_mode';

  bool _isDarkMode = false;
  ThemeData _themeData = AppTheme.lightTheme();

  ThemeProvider() {
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeData get themeData => _themeData;

  /// 앱 시작 시 저장된 테마 설정 로드
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getBool(_themePreferenceKey);

      if (savedTheme != null) {
        // 저장된 설정 적용
        setTheme(savedTheme);
      } else {
        // 시스템 설정 확인
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        setTheme(brightness == Brightness.dark);
      }
    } catch (e) {
      print('테마 설정 로드 중 오류 발생: $e');
      // 오류 발생 시 기본값(라이트 모드) 사용
      setTheme(false);
    }
  }

  /// 테마 변경
  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    _themeData = isDark ? AppTheme.darkTheme() : AppTheme.lightTheme();
    _saveThemePreference();
    notifyListeners();
  }

  /// 테마 토글 (현재 설정 반전)
  void toggleTheme() {
    setTheme(!_isDarkMode);
  }

  /// 테마 설정 저장
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, _isDarkMode);
    } catch (e) {
      print('테마 설정 저장 중 오류 발생: $e');
    }
  }
}
