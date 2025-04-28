import 'dart:io';
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

// SSL 인증서 오류 처리
class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  // SSL 인증서 오류 처리 설정
  HttpOverrides.global = CustomHttpOverrides();

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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 테마 프로바이더 사용
    return Consumer<ThemeProvider>(
      builder:
          (context, themeProvider, _) => MaterialApp(
            title: "디미플랜",

            // 다국어 지원 설정
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
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

            // 루트
            routes: {'/nav': (context) => const Nav()},
          ),
    );
  }
}
