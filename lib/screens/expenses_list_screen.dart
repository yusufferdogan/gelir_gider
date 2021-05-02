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

class ExpensesListScreen extends StatefulWidget {
  @override
  _ExpensesListScreenState createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  var languageIndex;

  void _getPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    languageIndex = prefs.getInt('language') ?? 0;
    Provider.of<Languages>(context, listen: false).setLanguage(languageIndex);
  }

  @override
  void initState() {
    super.initState();
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
  void didChangeDependencies() {
    _getPrefs();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final _theme = Provider.of<ThemeProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;
    var isDark = _theme.getTheme() == _theme.dark;


    return SafeArea(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          endDrawer: MainDrawer(),
          key: scaffoldKey,
          appBar: PreferredSize(
            preferredSize: size / 6,
            child: Consumer<Expenses>(
              builder: (context, provider, child) {
                return GradientAppBar(
                  leading: provider.tabBarIndex == 3 && provider.selectedPage != 0
                      ? GestureDetector(
                    onTap: () => provider.previousPage(),
                    child: Container(
                      margin : EdgeInsets.fromLTRB(10, 2, 0, 2),
                      child: Row(
                        children: [
                          Expanded(
                            flex:2,
                            child: Icon(Icons.arrow_back_ios,
                                size: size.width*0.05,
                                color: Colours.getBlackOrWhite(isDark)),
                          ),
                          Expanded(
                            flex:3,
                            child: Text("Geri",
                                style: TextStyle(
                                    color: Colours.getBlackOrWhite(isDark))),
                          ),
                        ]
                      ),
                    ),
                  )
                      : Container(),
                  shape: Border(
                      bottom: BorderSide(
                          width: 3.0 * textScaleFactor,
                          color: Colours.getGradientNew(isDark))),
                  title: Icon(
                    Icons.attach_money,
                    size: size.height * 0.035,
                    color: Theme.of(context).buttonColor,
                  ),
                  centerTitle: true,
                  actions: [DrawerButton(scaffoldKey: scaffoldKey)],
                  gradient: LinearGradient(
                    colors: Colours.getGradientNew2(isDark),
                  ),
                  bottom: TabBar(
                    controller: _controller,
                    unselectedLabelColor:
                        isDark ? Colors.grey[400] : Colors.grey[600],
                    labelColor: isDark ? Colors.pink : Colors.pink,
                    labelStyle: TextStyle(
                      fontSize: 15 * MediaQuery.of(context).textScaleFactor,
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
                    builder: (context, provider, child) {
                      return provider.tabBarIndex == 3
                          ? Container(
                              child: YearPage(),
                            )
                          : checkItemsAllEmpty(provider.currentItems.values)
                              ? child
                              : Column(
                                  children: [
                                    SizedBox(height: size.height * 0.015),
                                    MoneyWidget(returnCurrentList(provider)),
                                    SizedBox(height: size.height * 0.01),
                                    Divider(
                                        thickness: 1.7 *
                                            MediaQuery.of(context)
                                                .textScaleFactor,
                                        color: Colours.getBlackOrWhite(isDark)),
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
                    child: Center(
                      child: Text(
                        S.of(context).ExpenseListNoneExpense,
                        textAlign: TextAlign.center,
                      ),
                    ),
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

  List<Expense> returnCurrentList(Expenses provider) {
    var list = <Expense>[];
    provider.currentItems.values.forEach((element) {
      list = list + element;
    });
    return list;
  }
}

bool checkItemsAllEmpty(Iterable<List<Expense>> values) {
  var isEmpty=true;
  values.forEach((element) {
    if(element.isNotEmpty) {
    isEmpty=false;
    return isEmpty;
  }
  });
  return isEmpty;
}