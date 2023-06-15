import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/GetBill.dart';
import 'package:restismob/global.dart' as global;

import '../screens/CurrentBill.dart';

class TablesTableItem extends StatefulWidget {
  const TablesTableItem({super.key, required this.tableNumber, required this.isUsed});

  final int tableNumber;
  final int isUsed;

  @override
  State<TablesTableItem> createState() => _TablesTableItemState();
}

class _TablesTableItemState extends State<TablesTableItem> {
  Color backColor = const Color(0xffffffff);

  @override
  Widget build(BuildContext context) {
    Color fontColor;
    if (widget.isUsed == 0) {
      fontColor = Colors.black;
    } else {
      backColor = const Color(0xFFEEEEEE);
      fontColor = Colors.black45;
    }
    return SizedBox(
      height: 60,
      width: 60,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: backColor, boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 3.0, // soften the shadow
            spreadRadius: 2.0, //extend the shadow
          )
        ]),
        child: TextButton(
          child: Text(
            widget.tableNumber.toString(),
            style: TextStyle(fontSize: 14, color: fontColor),
          ),
          onPressed: () {
            if (!global.isSnackbarActive) {
              setState(() {
                global.isSnackbarActive = true;
                backColor = const Color(0xffB5F4B3);
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        content: Container(
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xffE4E4E4), width: 3),),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'Выбран стол № ${widget.tableNumber}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Roboto",
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextButton(
                                onPressed: () => newBill(),
                                child: const Text(
                                  'ПРОДОЛЖИТЬ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xffB4F4B3)
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                    .closed
                    .then((value) => setState(() {
                          backColor = const Color(0xffffffff);
                          global.isSnackbarActive = false;
                        }));
              });
            }
          },
        ),
      ),
    );
  }

  Future<void> newBill() async {
    GetBill? getBill;
    var dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15)));
    String request = 'http://${global.uri}/apim/GetTables';
    final response = await dio.post(request,
        data:
            '{"Head" : {"ID_WAITER":${global.waiter.user!.idcode},"TABLE_NUMBER":${widget.tableNumber},"GUESTS_COUNT":1}}');
    debugPrint(response.data!.toString());
    if (response.statusCode == 200) {
      getBill = GetBill.fromJson(response.data);
      if (getBill.root!.msgStatus!.msg!.idStatus == 0) {
        if (getBill.root!.billHead!.head!.idcode == -1) {
          global.currentBill = getBill;
        }
        goToBill(getBill.root!.billHead!.head!.idcode!);
      } else {
        goMsg(getBill.root!.msgStatus!.msg!.msgError!);
      }
    } else {
      goMsg('Ошибка подключения');
    }
  }

  void goMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
    ));
  }

  void goToBill(int idCode) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CurrentBill(idCode)));
  }
}
