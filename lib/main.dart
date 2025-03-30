import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dimiplan/views/nav_bar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:xtyle/xtyle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  Xtyle.init(
    configuration: XtyleConfig.korean(
      fontFamilyKor: 'NotoSansKR',
      defaultFontFamily: 'Montserrat',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dimiplan",
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko')],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(219, 32, 125, 1.0),
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity
        ),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(219, 32, 125, 1.0),
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          brightness: Brightness.dark
        ),
        brightness: Brightness.dark,
      ),
      home: const Nav(),
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: child!
      ),
    );
  }
}
