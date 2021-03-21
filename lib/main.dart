import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gelir_gider/providers/ad_state.dart';
import 'package:gelir_gider/providers/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:gelir_gider/providers/theme_provider.dart';
import 'package:gelir_gider/generated/l10n.dart';
import 'package:gelir_gider/screens/expenses_list_screen.dart';
import 'package:gelir_gider/providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gelir_gider/themes/colours.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gelir_gider/providers/ad_state.dart';

void main() async {
  // Uygulama ilk açıldığı vakit cihazda varsıyalan bir tema seçimi olup olmadığını
  // kontrol ediyoruz

  WidgetsFlutterBinding.ensureInitialized();
  final initFuture = MobileAds.instance.initialize();
  final adState = AdState(initFuture);
  var prefs = await SharedPreferences.getInstance();
  var isDarkTheme = prefs.getBool('isLight') ?? true;

  runApp(
    // Providerlarımızın programa dahil edilmesi işlemi
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Expenses>(
          create: (context) => Expenses(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          child: MyApp(),
          create: (BuildContext context) {
            return ThemeProvider(isDarkTheme);
          },
        ),
        ChangeNotifierProvider(
          create: (context) => Languages(),
        ),
        Provider.value(
          value: adState,
          builder: (context,child) => MyApp(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, value, child) {
        return MaterialApp(
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          color: Colours.colorGradient1, // Uygulamanın varsayılan rengi
          supportedLocales: S.delegate.supportedLocales,
          title: 'Gelir/Gider', // Uygulama ismi
          theme: value.getTheme(), // Temamız
          debugShowCheckedModeBanner: false,
          home: ExpensesListScreen(), // Açılış ekranımız
        );
      },
    );
  }
}
