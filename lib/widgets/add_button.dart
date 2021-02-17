import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gelir_gider/modals/custom_theme_modal.dart';


class AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _theme = Provider.of<CustomThemeModal>(context, listen: false);
    return Container(
      width: 60,
      height: 60,
      child: Icon(
        Icons.add,
        size: 40,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: _theme.getThemeData.brightness == Brightness.dark
            ? [Color(0xff212121), Color(0xff212121)]
            : [Colors.purple, Colors.pink]),
      ),
    );
  }
}
