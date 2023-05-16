import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:list_ext/list_ext.dart';

import 'package:restismob/global.dart' as global;
import 'package:restismob/models/localTypes/TextInputAlert.dart';

import '../models/BillCondiment.dart';
import '../models/Line.dart';
import '../models/localTypes/condimAlert.dart';
import '../models/localTypes/qoAlert.dart';
import '../models/menu/Condiment.dart';
import '../models/menu/MenuLine.dart';
import 'MenuWithTab.dart';

class GuestScreen extends StatelessWidget {
  final int gN;

  const GuestScreen(this.gN, {super.key});

  @override
  Widget build(BuildContext context) {
    guestNumber = gN;
    return const SafeArea(
      child: GuestMeal(),
    );
  }
}

Future<List<Line>> editedLines(int gnumber) async {
  List<Line> listOfLines = [];
  if (global.currentBill.root!.billLines!.line != null) {
    for (var element in global.currentBill.root!.billLines!.line!) {
      if ((element.gnumber == gnumber) && (element.idfline == 0) && (element.quantity! > 0)) {
        listOfLines.add(element);
      }
    }
  } else {
    global.currentBill.root!.billLines!.line = [];
  }
  return listOfLines;
}

int guestNumber = 0;

AutoDisposeFutureProvider<List<Line>> listGuestProvider = FutureProvider.autoDispose<List<Line>>((ref) async {
  return await editedLines(guestNumber);
});

final fabHeightProvider = StateProvider<double>((ref) {
  return 120;
});

class GuestMeal extends ConsumerWidget {
  const GuestMeal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var listOfLinesAsync = ref.watch(listGuestProvider);
    List<Line> listOfLines = [];
    if (listOfLinesAsync.value != null) {
      listOfLines = listOfLinesAsync.value!;
    }
    List<MenuLine> listOfMenuLines = [];
    List<Line> poplistOfLines = [];
    for (var element in global.menuStructure.menus!.menu!.menuHead!) {
      if (element.idtype!.contains('ALACA')) {
        element.menuLine!.sort((a, b) => b.weight!.compareTo(a.weight!));
        listOfMenuLines.addAll((element.menuLine!.take(10)).toList());
      }
      listOfMenuLines.sort((a, b) => b.weight!.compareTo(a.weight!));
    }
    for (var element in listOfMenuLines) {
      poplistOfLines.add(global.billLineFromMenuLine(element));
    }

    ScrollController listScrollController = ScrollController();

    var appBar = AppBar(
      backgroundColor: const Color(0xff6D1064),
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
      title: Text(
        "Гость $guestNumber",
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    return FocusDetector(
      onVisibilityGained: () {
        ref.invalidate(listGuestProvider);
      },
      child: Scaffold(
          appBar: appBar,
          body: Column(
            children: [
              Flexible(
                flex: 8,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 10 * 7, // Also Including Tab-bar height.
                  child: ListTileTheme(
                    contentPadding: const EdgeInsets.all(5),
                    iconColor: Colors.black54,
                    textColor: Colors.black,
                    tileColor: const Color(0xffEDF0F1),
                    style: ListTileStyle.list,
                    dense: true,
                    child: ListView.builder(
                      controller: listScrollController,
                      shrinkWrap: true,
                      itemCount: listOfLines.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (_, index) => Card(
                        margin: const EdgeInsets.all(5),
                        child: // ListTileItem(
                            //line: listOfLines[index],
                            // index: index,
                            // ),
                            ListTile(
                          title: Text(listOfLines[index].dispname!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w800,
                              )),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black26, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                  //  ((listOfLines[index].quantity! != 0) &&
                                  //          (listOfLines[index].quantity! > listOfLines[index].markquantity!))
                                        markNotSended(listOfLines[index])
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.remove,
                                              size: 16,
                                            ),
                                            onPressed: () {
                                              if ((listOfLines[index].idline! < 0) ||
                                                  (listOfLines[index].quantity! >
                                                      listOfLines[index].markquantity!)) {
                                                listOfLines[index].quantity =
                                                    listOfLines[index].quantity! - 1;
                                                if (listOfLines[index].iscomplex == 1) {
                                                  for (var element
                                                      in global.currentBill.root!.billLines!.line!) {
                                                    if (element.idfline == listOfLines[index].idline) {
                                                      element.quantity =
                                                          element.quantity! - element.complexquantity!;
                                                    }
                                                  }
                                                }
                                                ref.invalidate(listGuestProvider);
                                              }
                                            },
                                          )
                                        : Container(),
                                    Text((listOfLines[index].quantity!).toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.w800,
                                        )),
                                    IconButton(
                                        icon: const Icon(
                                          Icons.add,
                                          size: 16,
                                        ),
                                        onPressed: () {
                                          listOfLines[index].quantity = listOfLines[index].quantity! + 1;
                                          if (listOfLines[index].iscomplex == 1) {
                                            for (var element in global.currentBill.root!.billLines!.line!) {
                                              if (element.idfline == listOfLines[index].idline) {
                                                element.quantity =
                                                    element.quantity! + element.complexquantity!;
                                              }
                                            }
                                          }
                                          ref.invalidate(listGuestProvider);
                                        }),
                                  ],
                                ),
                              ),
                              PopupMenuButton(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (String item) {
                                  if (item.contains('del')) {
                                    if (markNotSended(listOfLines[index])) {
                                      listOfLines[index].quantity = 0;
                                      ref.invalidate(listGuestProvider);
                                    }
                                  }
                                  if (item.contains('cond')) {
                                    BillCondiment bc;
                                    Condiment sc;
                                    showDialog(
                                            builder: (_) => CondAlert(
                                                  condiments:
                                                      global.menuStructure.menus!.condiments!.condiment!,
                                                  group: listOfLines[index].group,
                                                ),
                                            context: context)
                                        .then((value) => {
                                              if (value != null)
                                                {
                                                  bc = BillCondiment(),
                                                  sc = value,
                                                  global.srvIdLine--,
                                                  bc.pkid = global.srvIdLine,
                                                  bc.idline = listOfLines[index].idline,
                                                  bc.idware = listOfLines[index].idware,
                                                  bc.idfware = sc.idfware,
                                                  bc.idcode = sc.idcode,
                                                  bc.idfgroup = sc.idfgroup,
                                                  bc.dispname = sc.dispname,
                                                  bc.idbill = listOfLines[index].idbill,
                                                  bc.idcondiment = sc.idcode,
                                                  global.currentBill.root!.billCondiments!.condiment!.add(bc),
                                                }
                                            });
                                  }
                                  if (item.contains('message')) {
                                    BillCondiment bc;
                                    showDialog(
                                        builder: (_) => const TextInputAlert(
                                          title: 'Введите комментарий',
                                        ),
                                        context: context)
                                        .then((value) => {
                                      if (value != null)
                                        {
                                          bc = BillCondiment(),
                                          global.srvIdLine--,
                                          bc.pkid = global.srvIdLine,
                                          bc.idline = listOfLines[index].idline,
                                          bc.idware = listOfLines[index].idware,
                                          bc.idfware = -1,
                                          bc.idcode = -1,
                                          bc.idfgroup = -1,
                                          bc.dispname = value,
                                          bc.idbill = listOfLines[index].idbill,
                                          bc.idcondiment = -1,
                                          global.currentBill.root!.billCondiments!.condiment!.add(bc),
                                        }
                                    });
                                  }
                                },
                                itemBuilder: (BuildContext bc) {
                                  return [
                                    PopupMenuItem(
                                      value: '/del',
                                      child: Column(
                                        children: [
                                          Row(
                                            children: const <Widget>[
                                              Text("Удалить"),
                                              Spacer(),
                                              Icon(
                                                Icons.delete_forever_outlined,
                                                color: Colors.black45,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: '/cond',
                                      child: Row(
                                        children: <Widget>[
                                          const Text("Модификатор"),
                                          const Spacer(),
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: SvgPicture.asset(
                                              'assets/images/modif.svg',
                                              semanticsLabel: 'vector',
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: '/message',
                                      child: Row(
                                        children: <Widget>[
                                          const Text("Комментарий"),
                                          const Spacer(),
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: SvgPicture.asset(
                                              'assets/images/message.svg',
                                              semanticsLabel: 'vector',
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ];
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                  child: Container(
                height: 48,
                width: 213.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xff6D1064),
                ),
                child: TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                      ),
                      Text("Добавить блюдо",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Montserrat",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => MenuWithTab(guestNumber)));
                  },
                ),
              )),
              Container(
                alignment: Alignment.bottomCenter,
                child: Center(
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(
                      Icons.star,
                      color: Colors.black38,
                    ),
                    TextButton(
                        child: const Text("Популярные позиции",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Montserrat",
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            )),
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height * .45,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.black38,
                                        ),
                                        TextButton(
                                            child: const Text("Популярные позиции",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: "Montserrat",
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                            onPressed: () => Navigator.of(context).pop()),
                                      ]),
                                      Flexible(
                                        child: ListView.builder(
                                          itemCount: poplistOfLines.length,
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (_, index) => Card(
                                            margin: const EdgeInsets.all(5),
                                            child: ListTile(
                                                title: Text(poplistOfLines[index].dispname!,
                                                    style: const TextStyle(
                                                      color: Colors.black45,
                                                      fontSize: 14,
                                                      fontFamily: "Montserrat",
                                                      fontWeight: FontWeight.w800,
                                                    )),
                                                //  subtitle: Text(_items[index]['subtitle']),
                                                trailing: IconButton(
                                                  icon:  global.ifLineInLines(poplistOfLines[index].idware!, guestNumber)
                                                      ? const Icon(
                                                    Icons.check_circle,
                                                    color: Color(0xff1A69A3),
                                                  )
                                                      : (poplistOfLines[index].quantity! < 0
                                                      ?  const Icon(Icons.block, color: Colors.red)
                                                      : const Icon(Icons.add_circle_outline)),
                                                  onPressed: () {
                                                    if (poplistOfLines[index].quantity! < 0){
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
                                                            builder: (_) => qoAlert(
                                                                ware: poplistOfLines[index].dispname!),
                                                            context: context)
                                                        .then((value) {
                                                      if (value != null) {
                                                        global.addNewLine(poplistOfLines[index], guestNumber,
                                                            value[0], value[1], context);
                                                        ref.invalidate(listGuestProvider);
                                                        Navigator.of(context).pop();
                                                        if (listScrollController.hasClients) {
                                                          final position =
                                                              listScrollController.position.maxScrollExtent;
                                                          listScrollController.jumpTo(position);
                                                        }
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
                                  ),
                                ),
                              );
                            },
                          );
                        })
                  ]),
                ),
              ),
            ],
          )),
    );
  }
  bool markNotSended(Line line){
    bool result = false;
    if (line.iscomplex == 1){
      Line? l = global.currentBill.root!.billLines!.line!.firstWhereOrNull((element) => element.idfline == line.idline);
      if (l != null){
      result = (l.quantity != 0) && (l.quantity! > l.markquantity!);}
      else {
        result = (line.quantity != 0) && (line.quantity! > line.markquantity!);
      }
    } else {
      result = (line.quantity != 0) && (line.quantity! > line.markquantity!);
    }
    return result;
  } 
}
