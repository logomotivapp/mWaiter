import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restismob/screens/BillListPage.dart';
import 'package:focus_detector/focus_detector.dart';

import '../global.dart';
import '../models/PreBills.dart';
import '../models/Bill.dart';
import '../global.dart' as global;
import '../models/menu/MenuStructure.dart';
import 'emptyBillList.dart';
import 'package:restismob/widgets/myProgressIndicator.dart';

class PreBillList extends ConsumerStatefulWidget {
  final num waiterId;

  const PreBillList(this.waiterId, {super.key});

  @override
  ConsumerState<PreBillList> createState() => PreBillListHome();
}

class PreBillListHome extends ConsumerState<PreBillList> {
  void refreshBillList() {
    ref.invalidate(listProvider);
  }

  @override
  Widget build(BuildContext context) {
    int percent = ref.watch(global.percentProvider);
    var menuStructure = ref.watch(menuProvider);
    global.srvIdLine = 0;
    var appBar = AppBar(
      backgroundColor: const Color(0xff68a3ab),
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
      title: const Text(
        "Заказы",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
            onPressed: () {
              setState(() {
                ref.invalidate(listProvider);
              });
            },
            icon: const Icon(Icons.refresh))
      ],
      bottom: const TabBar(tabs: [
        Tab(
          text: 'Все',
        ),
        Tab(
          text: 'Мои',
        )
      ]),
    );
    return FocusDetector(
      onVisibilityGained: () {
        ref.invalidate(listProvider);
      },
      child: WillPopScope(
        onWillPop: () async {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Вы хотите завершить?'),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Да'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('Нет'),
                  ),
                ],
              );
            },
          );
          return shouldPop!;
        },
        child: Scaffold(
            body: menuStructure.when(
          data: (menuStructure) {
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: appBar,
                body: TabBarView(
                  children: [
                    PreBillListList(widget.waiterId),
                    PreBillListListMy(widget.waiterId),
                  ],
                ),
              ),
            );
          },
          error: (err, stack) => Text('Error: $err'),
          loading: () =>  SafeArea(
            child: Scaffold(
              backgroundColor: Color(0xffedf0f1),
              body: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MyProgressIndicator(
                      text: 'Загружаю МЕНЮ',
                    ),
                    Text('${percent} %', style: const TextStyle(
                        color: Color(0xff8d96b6),
                        fontFamily: 'Montserrat',
                        fontSize: 23.804527282714844,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w800,
                        height: 1.5 /*PERCENT not supported*/
                    ),)
                  ],
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }

  ConsumerState<PreBillList> createState() => PreBillListHome();
}

class PreBillListList extends ConsumerWidget {
  const PreBillListList(this.waiterId, {super.key});

  final num waiterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    global.ref1 = ref;
    global.context1 = context;
    List<Bill?> billList = [];
    global.isLoading = ref.watch(loadProvider);
    var preBillList = ref.watch(listProvider);

    return Scaffold(
      body: Container(
        child: preBillList.when(
          data: (preBillList) {
            if (preBillList.preBills != null) {
              if (preBillList.preBills!.bill != null) {
                for (var element in preBillList.preBills!.bill!) {
                  if (element != null) {
                    billList.add(element);
                  }
                }
                if (billList.isEmpty) {
                  return const EmptyBillList();
                } else {
                  return BillListPage(billList);
                }
              } else {
                return const EmptyBillList();
              }
            } else {
              return const EmptyBillList();
            }
          },
          error: (err, stack) => Text('Error: $err'),
          loading: () => const MyProgressIndicator(),
        ),
      ),
    );
  }
}

class PreBillListListMy extends ConsumerWidget {
  const PreBillListListMy(this.waiterId, {super.key});

  final num waiterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    global.ref1 = ref;
    global.context1 = context;
    List<Bill?> billList = [];
    global.isLoading = ref.watch(loadProvider);
    var preBillList = ref.watch(listProvider);
    return Scaffold(
      body: Container(
        child: preBillList.when(
          data: (preBillList) {
            if (preBillList.preBills != null) {
              if (preBillList.preBills!.bill != null) {
                for (var element in preBillList.preBills!.bill!) {
                  if (element != null) {
                    if (element.idwaiter == waiterId) {
                      billList.add(element);
                    }
                  }
                }
                if (billList.isEmpty) {
                  return const EmptyBillList();
                } else {
                  return BillListPage(billList);
                }
              } else {
                return const EmptyBillList();
              }
            } else {
              return const EmptyBillList();
            }
          },
          error: (err, stack) => Text('Error: $err'),
          loading: () => MyProgressIndicator(),
        ),
      ),
    );
  }
}

Future<preBillList> loadPreBillList(num waiterId) async {
  preBillList? pBillList;
  var dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15)));
  String request = 'http://${global.uri}/apim/GetPreBills?Id_Waiter=${waiterId.toString()}';
  final response = await dio.get(request);
  debugPrint(response.data!.toString());
  if (response.statusCode == 200) {
    pBillList = preBillList.fromJson(response.data);
    if (pBillList.preBills != null) {
      pBillList.preBills!.bill!.removeWhere((element) => element != null ? element.tablenumber! == 0 : true);
    }
  } else {
    pBillList = null;
  }
  return pBillList!;
}

AutoDisposeFutureProvider<preBillList> listProvider = FutureProvider.autoDispose<preBillList>((ref) async {
  return await loadPreBillList(global.waiter.user!.idcode!);
});

AutoDisposeFutureProvider<MenuStructure> menuProvider =
    FutureProvider.autoDispose<MenuStructure>((ref) async {
  return await loadMenu();
});

Future<MenuStructure> loadMenu() async {
  var dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15)));
  String request = 'http://${global.uri}/apim/GetMenus';
  final response = await dio.get(request, onReceiveProgress: (count, total) {
    debugPrint('count $count total $total percent ${count / total * 100}');
    ref1!.read(global.percentProvider.notifier).state = (count / total * 100).round();
  });
  if (response.statusCode == 200) {
    global.menuStructure = MenuStructure.fromJson(response.data);
    return global.menuStructure;
  } else {
    return MenuStructure();
  }
}