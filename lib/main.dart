import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linkmanager/page/about/about.dart';
import 'package:linkmanager/page/branch/branch.dart';
import 'package:linkmanager/page/loading.dart';
import 'package:linkmanager/page/registration/login.dart';
import 'package:linkmanager/page/report.dart';
import 'package:linkmanager/page/url/home.dart';
import 'package:linkmanager/translation/AppLocalizations.dart';
import 'package:linkmanager/translation/appLanguage.dart';
import 'package:provider/provider.dart';

void main() async {
  statusBarColor();
  WidgetsFlutterBinding.ensureInitialized();
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  runApp(MyApp(
    appLanguage: appLanguage,
  ));
}

statusBarColor(){
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white, // status bar color
    statusBarBrightness: Brightness.dark,//status bar brigtness
    statusBarIconBrightness:Brightness.dark ,
  ));
}

class MyApp extends StatelessWidget {
  final AppLanguage appLanguage;

  MyApp({this.appLanguage});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguage>(
      create: (_) => appLanguage,
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return MaterialApp(
          locale: model.appLocal,
          supportedLocales: [
            Locale('en', ''),
            Locale('zh', ''),
            Locale('ms', ''),
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate
          ],
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Colors.white,
            accentColor: Colors.deepPurple,
            textTheme: GoogleFonts.notoSansTextTheme(
              Theme.of(context).textTheme,
            ),
            appBarTheme: Theme.of(context)
                .appBarTheme
                .copyWith(brightness: Brightness.light),
          ),
          routes: {
            '/': (context) => LoadingPage(),
            '/home': (context) => HomePage(),
            '/branch': (context) => BranchPage(),
            '/about': (context) => AboutPage(),
            '/login': (context) => LoginPage(),
            '/report': (context) => ReportPage()
          },
        );
      }),
    );
  }
}
