import 'package:flutter/material.dart';
import 'package:restismob/screens/ComplexToSelect.dart';

import '../models/menu/MenuHead.dart';
import 'package:restismob/global.dart' as global;

class ComplexList extends StatefulWidget {
  final List<MenuHead> listComplexHead;
  final int guestNum;

  const ComplexList({super.key, required this.listComplexHead, required this.guestNum});

  @override
  State<ComplexList> createState() => ComplexListState();
}

class ComplexListState extends State<ComplexList> {
  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      backgroundColor: Colors.lightGreen,
      centerTitle: true,
      leading: InkWell(
        onTap: () {
          //global.navKey.currentState!.pop();
          Navigator.of(context).maybePop();
        },
        child: const Icon(
          Icons.arrow_back,
          color: Colors.white60,
        ),
      ),
      title: SizedBox(
        height: 48,
        child: Text(
          'КОМПЛЕКСЫ',
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
            fontSize: 22,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return SafeArea(
      child: Scaffold(
        appBar: appBar,
        backgroundColor: const Color(0xffEDF0F1),
        body: ListView.builder(
          itemCount: widget.listComplexHead.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (_, index) => Card(
            margin: const EdgeInsets.all(5),
            child: ListTile(
              title: Text(widget.listComplexHead[index].dispname!,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w800,
                  )),
              //  subtitle: Text(_items[index]['subtitle']),
              trailing: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComplexToSelect(
                        menuHead: widget.listComplexHead[index],
                        guestNum: widget.guestNum,
                      ),
                    ),
                  ).then((value){ setState(() { });});
                },
                icon: global.ifLineInLines(widget.listComplexHead[index].idcode!, widget.guestNum)
                    ? const Icon(Icons.check_circle, color: Color(0xff1A69A3))
                    : Icon(Icons.add_circle_outline),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
