import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:restismob/screens/tablesList.dart';

import 'package:restismob/models/Bill.dart';
import '../widgets/tableListItem.dart';
import 'package:restismob/widgets/myFloatingButton.dart';

class BillListPage extends HookWidget {
  final List<Bill?> bills;


  const BillListPage(this.bills, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEDF0F1),
      body: GridView.count(
        childAspectRatio: 20/21,
        crossAxisCount: 2,
        children: <Widget>[..._listado(context, bills)],
      ),
      floatingActionButton: MyFloatingBunnon(
        width: 245,
        height: 48,
        borderColor: 0xff6b738e,
        fontColor: 0xff6b738e,
        backColor: 0xffEDF0F1,
        text: "Выбрать стол",
        onPress: () async {
          //await _toTableList();
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TablesList()));
        },
      ),
    );
  }

  List<Widget> _listado(BuildContext context, List<Bill?> lista) {
    List<Widget> listaWidget = [];
    for (var element in lista) {
      List<int> kurss = [];
      if (element!.iscurs2! == 1){ if (!kurss.contains(2)){kurss.add(2);}}
      if (element.iscurs3! == 1){ if (!kurss.contains(3)){kurss.add(3);}}
      String status = '';
      int lColor = 0;
      switch (element.ready) {
        case 0:
          {
            lColor = 0xffFFB5A5;
            status = 'В работе';
          }
          break;
        case 1:
          {
            lColor = 0xffFDE281;
            status = 'В работе';
          }
          break;
        case 2:
          {
            lColor = 0xff75F599;
            status = 'В работе';
          }
          break;
        default:{
          lColor = 0xffFFB5A5;
          status = 'В работе';
        }
          break;
      }
      listaWidget.add(TableItem(
        bill: element,
        hColor: lColor,
        kurss: kurss,
        status: status,
      ));
    }
    return listaWidget;
  }
}

