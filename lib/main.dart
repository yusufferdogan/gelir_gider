import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gelir_gider/screens/expenses_list_screen.dart';
import 'package:gelir_gider/providers/expense_provider.dart';
import 'package:gelir_gider/providers/language_provider.dart';
import 'package:gelir_gider/widgets/button_with_flag.dart';
import 'package:provider/provider.dart';
import 'package:theme_manager/theme_manager.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemeManager(
      defaultBrightnessPreference: BrightnessPreference.system,
      data: (Brightness brightness) => ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.lightBlue,
        brightness: brightness,
      ),
      loadBrightnessOnStart: true,
      themedWidgetBuilder: (BuildContext context, ThemeData theme) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: LanguageHandler(),
            ),
            ChangeNotifierProvider.value(
              value: Expenses(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: [GlobalMaterialLocalizations.delegate],
            supportedLocales: [const Locale('en'), const Locale('tr')],
            title: 'Gelir/Gider',
            theme: theme,
            debugShowCheckedModeBanner: false,
            home: WelcomeScreen(),
          ),
        );
      },
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FlagButton(
                  isEnglish: true,
                  onPressed: () {
                    Provider.of<LanguageHandler>(context, listen: false)
                        .setEnglish();
                    return Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => ExpensesListScreen()));
                  },
                  key: ValueKey(1),
                ),
                SizedBox(height: 100),
                FlagButton(
                  isEnglish: false,
                  onPressed: () {
                    Provider.of<LanguageHandler>(context, listen: false)
                        .setTurkish();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => ExpensesListScreen()));
                  },
                  key: ValueKey(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
