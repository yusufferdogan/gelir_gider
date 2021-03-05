import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gelir_gider/screens/year_page.dart';
import 'package:gelir_gider/widgets.dart';
import 'package:gelir_gider/providers/providers.dart';
import 'package:gelir_gider/generated/l10n.dart';
import 'package:gelir_gider/themes/colours.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gelir_gider/helpers/notification_helper.dart';

// Ana ekranın, tabbarlar arasındaki geçişlerde bulunan ekranların
// tasarımı ve tüm arkaplanının yapıldığı kısım

class ExpensesListScreen extends StatefulWidget {
  @override
  _ExpensesListScreenState createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  var languageIndex;

  Future<void> _getPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    languageIndex = prefs.getInt('language') ?? 0;
    Provider.of<Languages>(context, listen: false).setLanguage(languageIndex);
  }

  @override
  void initState() {
    super.initState();
    notificationPlugin
        .setListenerForLowerVersions(onNotificationInLowerVersions);
    notificationPlugin.setOnNotificationClick(onNotificationClick);
    notificationPlugin.showDailyAtTime();
    _getPrefs().then((value) => {});
    Future.delayed(Duration.zero).then((_) {
      Provider.of<Expenses>(context, listen: false).setCategories(context);
      _controller = TabController(length: 4, vsync: this);
      _controller.addListener(() {
        Provider.of<Expenses>(context, listen: false)
            .setTabBarIndex(_controller.index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final _theme = Provider.of<ThemeProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    var isDark = _theme.getTheme() == _theme.dark;


    return SafeArea(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          endDrawer: MainDrawer(),
          key: scaffoldKey,
          appBar: PreferredSize(
            preferredSize: size / 5.5,
            child: Consumer<Expenses>(
              builder: (context, value, child) {
                return GradientAppBar(
                  shape: Border(
                      bottom: BorderSide(
                          width: 3.0, color: Colours.getGradientNew(isDark))),
                  leading: AccountChanger(_controller),
                  centerTitle: true,
                  actions: [DrawerButton(scaffoldKey: scaffoldKey)],
                  title: Icon(
                    Icons.attach_money,
                    color: Theme.of(context).buttonColor,
                  ),
                  gradient: LinearGradient(
                    colors: Colours.getGradientNew2(isDark),
                  ),
                  bottom: TabBar(
                    controller: _controller,
                    unselectedLabelColor:
                        isDark ? Colors.grey[400] : Colors.grey[600],
                    labelColor: isDark ? Colors.pink : Colors.pink,
                    labelPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                    labelStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    tabs: <Widget>[
                      Tab(text: S.of(context).TabBarDay),
                      Tab(text: S.of(context).TabBarWeek),
                      Tab(text: S.of(context).TabBarMonth),
                      Tab(text: S.of(context).TabBarYear),
                    ],
                  ),
                );
              },
            ),
          ),
          body: FutureBuilder(
            future: Provider.of<Expenses>(context, listen: false)
                .fetchAndSetExpenses(),
            builder: (ctx, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Consumer<Expenses>(
                    child: Center(
                      child: Text(
                        S.of(context).ExpenseListNoneExpense,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    builder: (context, provider, child) {
                      return provider.TabBarIndex == 3
                          ? Container(
                              child: YearPage(),
                            )
                          : provider.currentItems.isEmpty
                              ? child
                              : Column(
                                  children: [
                                    SizedBox(height: size.height * 0.02),
                                    MoneyWidget(returnCurrentList(provider)),
                                    OurDivider(),
                                    Flexible(
                                      flex: 10,
                                      child: ListView.builder(
                                        itemCount: provider.currentItems.length,
                                        itemBuilder: (context, index) {
                                          provider.getSymbol();
                                          var category = provider
                                              .currentItems.keys
                                              .toList()[index];
                                          var list = provider
                                              .currentItems.values
                                              .toList()[index];
                                          var currency = provider.symbol;
                                          return Column(
                                            children: [
                                              MainPageCategoryModal(
                                                category: category,
                                                list: list,
                                                currency: currency,
                                              ),
                                              OurDivider(),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    BottomSpace(),
                                  ],
                                );
                    },
                  ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButtonAdd(
            scaffoldKey: scaffoldKey,
            context: context,
          ),
        ),
      ),
    );
  }

  List<Expense> returnCurrentList(Expenses provider){
    var list = <Expense>[];
    provider.currentItems.values.forEach((element) {
      list = list + element;
    });
    return list;
  }

  void onNotificationInLowerVersions(ReceivedNotification receivedNotification) {
    print('Notification Received ${receivedNotification.id}');
  }

  void onNotificationClick(String payload) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ExpensesListScreen();
    }));
  }
}
