import 'package:flutter/material.dart';

import '../menu/Condiment.dart';

class CondAlert extends StatefulWidget {
  final List<Condiment> condiments;
  final int? group;
  int idWare;

  CondAlert({super.key, required this.condiments, required this.group, this.idWare = 0});

  @override
  State<CondAlert> createState() => CondAlertState();
}

class CondAlertState extends State<CondAlert> {
  @override
  Widget build(BuildContext context) {
    List<Condiment> lc = [];
    if (widget.idWare > 0) {
      lc.addAll(widget.condiments.where((element) =>
          (element.idfware != null) && (element.idcode! > 0) &&
          ((element.idfware == widget.idWare) || (element.idfgroup == widget.group))));
    } else {
      if (widget.group != null) {
        lc.addAll(widget.condiments.where((element) =>
        (element.idcode! > 0) &&
            ((element.idfgroup == widget.group) || ((element.idfgroup == -1) && (element.idfware == -1)))));
      } else {
        lc.addAll(
            widget.condiments.where((element) => ((element.idcode! > 0) && (element.idfgroup == -1) && (element.idfware == -1))));
      }
    }
    lc.sort((a, b) => b.vorder!.compareTo(a.vorder!));
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      content: Column(
        children: [
          Flexible(
            child: ListView.builder(
              itemCount: lc.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (_, index) => Card(
                margin: const EdgeInsets.all(5),
                child: ListTile(
                  title: Text(lc[index].dispname!,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w800,
                      )),
                  //  subtitle: Text(_items[index]['subtitle']),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.pop(context, lc[index]);
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
