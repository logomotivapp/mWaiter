import 'package:flutter/material.dart';

import 'package:restismob/global.dart' as global;
import '../models/Line.dart';
import '../models/localTypes/qo_Alert.dart';

class MenuListRegular extends StatefulWidget {
  final int guestNumber;
  final List<Line> listOfLines;

  const MenuListRegular({super.key, required this.guestNumber, required this.listOfLines});

  @override
  State<MenuListRegular> createState() => MenuListRegularState();
}

class MenuListRegularState extends State<MenuListRegular> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Flexible(
          child: ListView.builder(
            itemCount: widget.listOfLines.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (_, index) => Card(
              margin: const EdgeInsets.all(5),
              child: ListTile(
                  title: Text(widget.listOfLines[index].dispname!,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w800,
                      )),
                  //  subtitle: Text(_items[index]['subtitle']),
                  trailing: IconButton(
                    icon: global.ifLineInLines(widget.listOfLines[index].idware!, widget.guestNumber)
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xff1A69A3),
                          )
                        : (widget.listOfLines[index].quantity! < 0
                            ?  const Icon(Icons.block, color: Colors.red)
                            : const Icon(Icons.add_circle_outline)),
                    onPressed: () {
                      if (widget.listOfLines[index].quantity! < 0){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            backgroundColor: Colors.redAccent,
                            content: Text(
                              'Бдюдо в стоп листе',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            )));
                      }
                      else {
                        showDialog(
                            builder: (_) => QoAlert(ware: widget.listOfLines[index].dispname!, guest: widget.guestNumber,),
                            context: context)
                            .then((value) {
                          if (value != null) {
                            global.addNewLine(
                                widget.listOfLines[index], value[2], value[0], value[1], context);
                            if (value[2] > global.currentBill.root!.billHead!.head!.guestscount){
                              global.currentBill.root!.billHead!.head!.guestscount = value[2];
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.black54,
                                content: Text(
                                  'Добавлено блюдо \n${widget.listOfLines[index].dispname!} \n порций ${widget
                                      .listOfLines[index].quantity} курс ${widget.listOfLines[index].norder}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                )));
                            setState(() {});
                          }
                        });
                      }},
                  )),
            ),
          ),
          //ListForSelectWares(
          // listOfLines: listOfLines, gnumber: gnumber,)
        ),
      ],
    ));
  }
}
