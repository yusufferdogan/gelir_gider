import 'package:flutter/material.dart';
import 'package:gelir_gider/providers/expense_provider.dart';
import 'package:gelir_gider/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:gelir_gider/widgets/dialogs/theme_dialog_widget.dart';
import 'package:gelir_gider/screens/language_selection_screen.dart';
import 'package:gelir_gider/generated/l10n.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:gelir_gider/themes/colours.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _theme = Provider.of<ThemeProvider>(context, listen: false);
    var isDark = _theme.getTheme() == _theme.dark;
    var provider = Provider.of<Expenses>(context, listen: false);
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    void showThemePicker() {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return ThemeDialogWidget();
        },
      );
    }

    return Drawer(
      child: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: Colours.getGradientColors(isDark)),
            ),
            child: DrawerHeader(
              child: Icon(
                Icons.attach_money,
                size: 50,
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(10, 18, 10, 18),
            onTap: () {
              Navigator.pop(context);
              showThemePicker();
            },
            title: Text(
              S.of(context).DrawerThemeText,
              style: TextStyle(fontSize: 18*textScaleFactor),
            ),
            leading: Icon(
              Icons.color_lens,
              size: 40,
              color: Theme.of(context).buttonColor,
            ),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(10, 18, 10, 18),
            onTap: () {
              return Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (ctx) => LanguageSelectionScreen(),
                ),
              );
            },
            title: Text(
              S.of(context).DrawerLanguageText,
              style: TextStyle(fontSize: 18*textScaleFactor),
            ),
            leading: Icon(
              Icons.language,
              size: 40,
              color: Theme.of(context).buttonColor,
            ),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(10, 18, 10, 18),
            onTap: () async {
              return await showCurrencyPicker(
                context: context,
                showFlag: true,
                showCurrencyName: true,
                showCurrencyCode: true,
                onSelect: (Currency currency) async {
                  print('Select currency symbol: ${currency.symbol}');
                  await provider.setCurrency(currency.symbol);
                  await Navigator.of(context).pop();
                },
              );
            },
            title: Text(
              S.of(context).DrawerSelectCurrency,
              style: TextStyle(fontSize: 18*textScaleFactor),
            ),
            leading: Icon(
              Icons.money,
              size: 40,
              color: Theme.of(context).buttonColor,
            ),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }
}