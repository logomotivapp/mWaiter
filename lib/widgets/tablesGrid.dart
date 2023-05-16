import 'package:flutter/material.dart';
import 'package:restismob/widgets/tablesTableItem.dart';

import '../models/Tables.dart';

class TablesGrid extends StatelessWidget {
  final List<Tables> tables;

  TablesGrid({super.key, required this.tables});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEDF0F1),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              'Выберите нужный стол\nдля оформления заказа:',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  letterSpacing: 0,
                  fontWeight: FontWeight.w800,
                  height: 1.5 /*PERCENT not supported*/),
            ),
          ),
          Flexible(
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: <Widget>[..._listado(context, tables)],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _listado(BuildContext context, List<Tables?> lista) {
    List<Widget> listaWidget = [];
    for (var element in lista) {
      listaWidget.add(TablesTableItem(
        tableNumber: element!.tablenumber,
        isUsed: element.isused,
      ));
    }
    return listaWidget;
  }
}
