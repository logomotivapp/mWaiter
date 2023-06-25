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
import '../models/localTypes/qo_Alert.dart';
import '../models/menu/Condiment.dart';
import 'BillImageText.dart';
import 'MenuWithTab.dart';

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
//    List<MenuLine> listOfMenuLines = [];
    List<Line> poplistOfLines = [];
    /*   for (var element in global.menuStructure.menus!.menu!.menuHead!) {
      if (element.idtype!.contains('ALACA')) {
        element.menuLine!.sort((a, b) => b.weight!.compareTo(a.weight!));
        listOfMenuLines.addAll((element.menuLine!.take(10)).toList());
      }
      listOfMenuLines.sort((a, b) => b.weight!.compareTo(a.weight!));
    }*/

    for (var element in global.fea.featuredRoot!.featuredItems!.item!) {
      poplistOfLines.add(global.billLineFromFeaLine(element));
    }

    ScrollController listScrollController = ScrollController();

    var appBar = AppBar(
      backgroundColor: const Color(0xff6D1064),
      //  centerTitle: true,
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
      actions: [
        IconButton(
          color: Colors.white,
          icon: const Icon(Icons.checklist_rtl_sharp),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BillImageText()));
          },
        ),
      ],
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
                flex: 7,
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
                      itemBuilder: (_, index) {
                        double hh = 0;
                        bool markS = markNotSended(listOfLines[index]);
                        List<Widget> listsOfWidgets = [];
                        List<BillCondiment> conds = global.currentBill.root!.billCondiments!.condiment!
                            .where((element1) => element1.idline == listOfLines[index].idline)
                            .toList();
                        if (conds.isNotEmpty) {
                          hh = 60 + (conds.length ~/ 2) * 65;
                          if (conds.length.remainder(2) != 0) {
                            hh = hh + 65;
                          }
                          for (var element3 in conds) {
                            listsOfWidgets.add(
                              Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8))),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      flex: 7,
                                      child: Text(element3.dispname!,
                                          maxLines: 2,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.w800,
                                              overflow: TextOverflow.ellipsis,
                                              color: Colors.grey)),
                                    ),
                                    markS
                                        ? Flexible(
                                            flex: 3,
                                            child: IconButton(
                                              onPressed: () {
                                                global.currentBill.root!.billCondiments!.condiment!
                                                    .removeWhere((elementC) =>
                                                        (elementC.idline == element3.idline) &&
                                                        (elementC.idware == element3.idware) &&
                                                        (elementC.idcondiment == element3.idcondiment) &&
                                                        elementC.pkid! < 0);
                                                ref.invalidate(listGuestProvider);
                                              },
                                              icon: const Icon(
                                                Icons.highlight_remove_sharp,
                                              ),
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                              ),
                            );
                          }
                        }
                        return Card(
                          borderOnForeground: true,
                          margin: const EdgeInsets.all(3),
                          child: SizedBox(
                            height: conds.isNotEmpty ? hh : 60,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  flex: conds.isNotEmpty ? 6 : 1,
                                  child: ListTile(
                                    title: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          flex: 2,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: markS
                                                    ? const Color(0xffEDF0F1)
                                                    : listOfLines[index].iscomplited == 1
                                                        ? const Color(0xff75F599)
                                                        : const Color(0xffFDE281),
                                                borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    bottomLeft: Radius.circular(8))),
                                            child: const SizedBox(
                                              width: 10,
                                              height: 60,
                                              child: Text(''),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 8,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 3),
                                            child: Text(listOfLines[index].dispname!,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.w800,
                                                  overflow: TextOverflow.ellipsis,
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
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
                                              markS
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
                                                            for (var element in global
                                                                .currentBill.root!.billLines!.line!) {
                                                              if (element.idfline ==
                                                                  listOfLines[index].idline) {
                                                                element.quantity = element.quantity! -
                                                                    element.complexquantity!;
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
                                                    listOfLines[index].quantity =
                                                        listOfLines[index].quantity! + 1;
                                                    if (listOfLines[index].iscomplex == 1) {
                                                      for (var element
                                                          in global.currentBill.root!.billLines!.line!) {
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
                                              if (markS) {
                                                listOfLines[index].quantity = listOfLines[index].markquantity;
                                                ref.invalidate(listGuestProvider);
                                              }
                                            }
                                            if (item.contains('cond')) {
                                              if (markS) {
                                                BillCondiment bc;
                                                Condiment sc;
                                                showDialog(
                                                        builder: (_) => CondAlert(
                                                              condiments: global.menuStructure.menus!
                                                                  .condiments!.condiment!,
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
                                                              global.currentBill.root!.billCondiments!
                                                                  .condiment!
                                                                  .add(bc),
                                                              ref.invalidate(listGuestProvider),
                                                            }
                                                        });
                                              }
                                            }
                                            if (item.contains('message')) {
                                              if (markS) {
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
                                                              bc.idfware = 0,
                                                              bc.idcode = -1,
                                                              bc.idfgroup = -1,
                                                              bc.dispname = value,
                                                              bc.idbill = listOfLines[index].idbill,
                                                              bc.idcondiment = -1,
                                                              global.currentBill.root!.billCondiments!
                                                                  .condiment!
                                                                  .add(bc),
                                                            }
                                                        });
                                              }
                                            }
                                            if (item.contains('complite')) {
                                              listOfLines[index].iscomplited = 1;
                                              ref.invalidate(listGuestProvider);
                                            }
                                          },
                                          itemBuilder: (BuildContext bc) {
                                            return [
                                              const PopupMenuItem(
                                                value: '/del',
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: <Widget>[
                                                        Text("Удалить"),
                                                        Spacer(),
                                                        Icon(
                                                          Icons.delete_forever_outlined,
                                                          color: Colors.black45,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
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
                                              const PopupMenuItem(
                                                value: '/complite',
                                                child: Row(
                                                  children: <Widget>[
                                                    Text("Готово"),
                                                    Spacer(),
                                                    Icon(Icons.check_circle_outline_sharp),
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
                                conds.isNotEmpty
                                    ? Flexible(
                                        flex: 4,
                                        child: Container(
                                          color: const Color(0xffEDF0F1),
                                          child: GridView.count(
                                            physics: const NeverScrollableScrollPhysics(),
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                            crossAxisCount: 2,
                                            childAspectRatio: 10 / 2,
                                            children: <Widget>[...listsOfWidgets],
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        );
                      },
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                      context,
                      MaterialPageRoute(
                          builder: (context) => MenuWithTab(
                                guestNum: guestNumber,
                                canSelect: true,
                              )),
                    );
                  },
                ),
              )),
              Flexible(
                child: SizedBox(
                  height: 52.12,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: Wrap(
                      spacing: 0,
                      children: [
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: SizedBox(
                              width: 58.66,
                              height: 3,
                              child: Divider(
                                thickness: 3,
                                color: Color(0xffCFD5EA),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(
                              Icons.star,
                              color: Colors.black38,
                            ),
                            TextButton(
                                child: const Text("Избранные позиции",
                                    style: TextStyle(
                                      height: 0.7,
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
                                                    child: const Text("Избранные позиции",
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
                                                          icon: global.ifLineInLines(
                                                                  poplistOfLines[index].idware!, guestNumber)
                                                              ? const Icon(
                                                                  Icons.check_circle,
                                                                  color: Color(0xff1A69A3),
                                                                )
                                                              : (poplistOfLines[index].quantity! < 0
                                                                  ? const Icon(Icons.block, color: Colors.red)
                                                                  : const Icon(Icons.add_circle_outline)),
                                                          onPressed: () {
                                                            if (poplistOfLines[index].quantity! < 0) {
                                                              ScaffoldMessenger.of(context)
                                                                  .showSnackBar(const SnackBar(
                                                                      backgroundColor: Colors.redAccent,
                                                                      content: Text(
                                                                        'Бдюдо в стоп листе',
                                                                        style: TextStyle(
                                                                          fontSize: 18,
                                                                        ),
                                                                        textAlign: TextAlign.center,
                                                                      )));
                                                            } else {
                                                              showDialog(
                                                                      builder: (_) => QoAlert(
                                                                          guest: guestNumber,
                                                                          ware: poplistOfLines[index]
                                                                              .dispname!),
                                                                      context: context)
                                                                  .then((value) {
                                                                if (value != null) {
                                                                  global.addNewLine(poplistOfLines[index],
                                                                      value[2], value[0], value[1], context);
                                                                  if (value[2] >
                                                                      global.currentBill.root!.billHead!.head!
                                                                          .guestscount) {
                                                                    global.currentBill.root!.billHead!.head!
                                                                        .guestscount = value[2];
                                                                  }
                                                                  ref.invalidate(listGuestProvider);
                                                                  //  Navigator.of(context).pop();
                                                                  if (listScrollController.hasClients) {
                                                                    final position = listScrollController
                                                                        .position.maxScrollExtent;
                                                                    listScrollController.jumpTo(position);
                                                                  }
                                                                }
                                                              });
                                                            }
                                                          },
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  bool markNotSended(Line line) {
    bool result = false;
    if (line.iscomplex == 1) {
      Line? l = global.currentBill.root!.billLines!.line!
          .firstWhereOrNull((element) => element.idfline == line.idline);
      if (l != null) {
        result = (l.quantity != 0) && (l.quantity! > l.markquantity!);
      } else {
        result = (line.quantity != 0) && (line.quantity! > line.markquantity!);
      }
    } else {
      result = (line.quantity != 0) && (line.quantity! > line.markquantity!);
    }
    return result;
  }
}

class GuestScreen extends StatefulWidget {
  final int gN;

  const GuestScreen({super.key, required this.gN});

  @override
  State<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> with WidgetsBindingObserver {
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        var result = global.saveCurrentBill();
        result.then((value) => {Navigator.popUntil(context, (route) => route.settings.name == "/prebills")});
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.resumed:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    guestNumber = widget.gN;
    return const SafeArea(
      child: GuestMeal(),
    );
  }
}
