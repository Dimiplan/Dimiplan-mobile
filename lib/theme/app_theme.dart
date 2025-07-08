import 'package:flutter/material.dart';
import 'package:color_shade/color_shade.dart';

/// 디미플랜 앱의 테마 시스템
/// 웹 버전과 통일된 디자인 시스템을 구현
class AppTheme {
  // 기본 테마 색상
  static const Color primaryColor = Color.fromRGBO(219, 32, 125, 1.0);
  static const Color primaryLight = Color.fromRGBO(255, 92, 184, 1.0);
  static const Color primaryDark = Color.fromRGBO(137, 20, 79, 1.0);

  // 테마 기본 색상
  static const Color background = Colors.white;
  static Color surface = Colors.white.shade50;
  static Color surfaceVariant = Colors.white.shade100;
  static Color textPrimary = Colors.grey.shade800;
  static Color textSecondary = Colors.grey.shade600;
  static Color textMuted = Colors.grey.shade500;
  static Color borderColor = Colors.grey.shade400;

  // 상태 색상
  static Color success = Colors.green.shade500;
  static Color warning = Colors.amber.shade600;
  static Color error = Colors.red.shade600;
  static Color info = Colors.blue.shade600;

  // 그림자
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.black.shade50,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.shade100,
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // 애니메이션 지속 시간
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // 라이트 테마
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: background,
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: textSecondary,
        indicatorColor: primaryColor,
      ),
      dialogTheme: const DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      disabledColor: Colors.blueGrey.shade400,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: borderColor, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        floatingLabelStyle: const TextStyle(color: primaryColor),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 12.0,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w800,
          fontSize: 30,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: textPrimary,
        ),
        labelSmall: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 24.0),
          textStyle: const TextStyle(
            fontFamily: 'NotoSansKR',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
    );
  }

  // 다크 테마
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryLight,
        brightness: Brightness.dark,
      ),
      primaryColor: primaryLight,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: const CardThemeData(
        color: Color(0xFF242424),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: primaryLight,
        unselectedItemColor: Color(0xFFCCCCCC),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryLight,
        unselectedLabelColor: Color(0xFFCCCCCC),
        indicatorColor: primaryLight,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF242424),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      disabledColor: Colors.blueGrey.shade600,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xFF2C2C2C),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF444444), width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: primaryLight, width: 2.0),
        ),
        floatingLabelStyle: const TextStyle(color: primaryLight),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 12.0,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w800,
          fontSize: 30,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: Color(0xFFCCCCCC),
        ),
        labelLarge: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.white,
        ),
        labelSmall: TextStyle(
          fontFamily: 'NotoSansKR',
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: Color(0xFFCCCCCC),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 24.0),
          textStyle: const TextStyle(
            fontFamily: 'NotoSansKR',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
    );
  }
}
