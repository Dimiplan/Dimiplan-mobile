import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dimiplan/views/nav_bar.dart';
import 'package:dimiplan/providers/auth_provider.dart';
import 'package:dimiplan/providers/theme_provider.dart';
import 'package:dimiplan/providers/planner_provider.dart';
import 'package:dimiplan/providers/ai_provider.dart';
import 'package:dimiplan/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:web/web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart' show kReleaseMode;

void main() async {
  // 웹인 경우 모바일 기기 확인 및 리다이렉트 (dev 브랜치에서는 비활성화)
  if (kIsWeb) {
    final userAgent = window.navigator.userAgent.toLowerCase();
    final isMobile =
        userAgent.contains('mobi') ||
        userAgent.contains('android') ||
        userAgent.contains('iphone') ||
        userAgent.contains('ipad');

    // dev 브랜치에서는 리다이렉트 비활성화
    const bool isDevBuild = bool.fromEnvironment('DEV_BUILD', defaultValue: false);
    
    if (!isMobile && kReleaseMode && !isDevBuild) {
      window.location.href = 'https://dimiplan.com';
      return;
    }
  }

  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 방향 설정 (세로 모드만 허용)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 앱 실행
  runApp(
    // 프로바이더 설정
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlannerProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 테마 프로바이더 사용
    return Consumer<ThemeProvider>(
      builder:
          (context, themeProvider, _) => MaterialApp(
            title: '디미플랜',

            // 다국어 지원 설정
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('ko')],

            // 디버그 배너 숨기기
            debugShowCheckedModeBanner: false,

            // 테마 설정
            theme: themeProvider.themeData,
            darkTheme: AppTheme.darkTheme(),
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // 홈 화면
            home: const Nav(),

            // 텍스트 스케일링 제한 (폰트 크기 일관성 유지)
            builder:
                (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: child!,
                ),
          ),
    );
  }
}
