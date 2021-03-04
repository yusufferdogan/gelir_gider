import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gelir_gider/providers/expense_provider.dart';
import 'package:gelir_gider/widgets/components/divider.dart';
import 'package:gelir_gider/widgets/dialogs/main_page_category_modal.dart';
import 'package:gelir_gider/widgets/year_page/month_item.dart';
import 'package:gelir_gider/widgets/year_page/week_item.dart';
import 'package:gelir_gider/widgets/year_page/day_item.dart';
import 'package:gelir_gider/widgets/year_page/year_item.dart';
import 'package:provider/provider.dart';
import 'package:gelir_gider/generated/l10n.dart';
import 'package:gelir_gider/widgets/components/money_widget.dart';

class YearPage extends StatefulWidget {
  @override
  _YearPageState createState() => _YearPageState();
}

class _YearPageState extends State<YearPage> {
  bool init = true;

  @override
  void didChangeDependencies() {
    if (init) {
      Provider.of<Expenses>(context, listen: false).setSelectedPage(0);
      init = false;
    }
    super.didChangeDependencies();
  }

  /* Widget _buildBody(title, Map<int, List<Expense>> list, onPressed, page) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FlatButton.icon(
            onPressed: onPressed,
            icon: SizedBox(
              width: 18.0,
              child: Icon(
                Icons.arrow_left_outlined,
                size: 35.0,
                color:  Theme.of(context).buttonColor,
              ),
            ),
            label: Text(
              title,
              style: TextStyle(
                color:  Theme.of(context).buttonColor,
                fontSize: 17.0,
                wordSpacing: 0.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            child: MoneyWidget(list),
          ),
          page,
        ],
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final monthNames = <String>[
      S.of(context).January,
      S.of(context).February,
      S.of(context).March,
      S.of(context).April,
      S.of(context).May,
      S.of(context).June,
      S.of(context).July,
      S.of(context).August,
      S.of(context).September,
      S.of(context).October,
      S.of(context).November,
      S.of(context).December,
    ];
    return Consumer<Expenses>(
      child: null,
      builder: (context, provider, child) {
        switch (provider.selectedPage) {
          case 0:
            var myList = provider.expense;
            var list = provider.getCurrentYears();
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  MoneyWidget(myList),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        provider.getSymbol();
                        var years = list.elementAt(index);
                        return Column(
                          children: [
                            YearListItem(
                              year: years,
                            ),
                            OurDivider(),
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            );
            break;
          case 1:
            var myList = provider.currentYear[provider.selectedYear];
            final list = provider.getCurrentMonths();
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  MoneyWidget(myList),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        provider.getSymbol();
                        var months = list.elementAt(index);
                        return Column(
                          children: [
                            MonthListItem(
                              title: monthNames[months - 1],
                              index: months - 1,
                            ),
                            OurDivider(),
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            );
            break;
          case 2:
            var myList = provider.currentMonth[provider.selectedMonth + 1];
            var weekButtons = <WeekItem>[];
            final lastDay = provider.getLastDayOfMonth();
            var weekDays = ['1-7', '8-14', '15-21', '22-' + lastDay.toString()];
            weekDays.forEach((weekText) {
              var startDay = int.parse(weekText.split('-')[0]);
              var endDay = int.parse(weekText.split('-')[1]);
              if (!provider.checkWeekNull(startDay, endDay)) {
                weekButtons.add(WeekItem(
                  title: weekText + ' ' + monthNames[provider.selectedMonth],
                ));
              }
            });
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  MoneyWidget(myList),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: weekButtons.length,
                      itemBuilder: (context, index) {
                        var weekButton = weekButtons[index];
                        return Column(
                          children: [
                            weekButton,
                            OurDivider(),
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            );
            break;

          case 3:
            var daysAndMonth = provider.selectedWeek;
            var days = daysAndMonth.split(' ')[0];
            var startDay = int.parse(days.split('-')[0]);
            var endDay = int.parse(days.split('-')[1]);
            var monthName = daysAndMonth.split(' ')[1];

            var dayButtons = <DayListItem>[];
            var curDays = provider.getCurrentDays(startDay, endDay);
            print(curDays.toString());
            var myList=<Expense>[];
            curDays.forEach((element) {
              if (element != null) {
                myList = myList+provider.currentDay[element];
                dayButtons.add(DayListItem(
                  title: element.toString() + ' ' + monthName,
                ));
              }
            });
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  MoneyWidget(myList),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: dayButtons.length,
                      itemBuilder: (context, index) {
                        var dayItem = dayButtons[index];
                        return Column(
                          children: [
                            dayItem,
                            OurDivider(),
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            );
            break;
          case 4:
            var res = provider.currentDay[provider.selectedDay];
            var myList = provider.groupExpensesByCategories(res);
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  MoneyWidget(res),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: myList.keys.length,
                      itemBuilder: (context, index) {
                        provider.getSymbol();
                        var category = myList.keys.toList()[index];
                        var list = myList.values.toList()[index];
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
                  )
                ],
              ),
            );
            break;
          default:
            return Container();
        }
      },
    );
  }
}
