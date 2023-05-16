import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'login.dart';
import 'global.dart' as global;

void main() {
  runApp(ProviderScope(child: MyApp()));
}

Future<void> _inPressed(BuildContext context) async {
  //await global.navKey.currentState!.push(MaterialPageRoute(builder: (context) => const Login()));
  await Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHome());
  }
}

class MyHome extends StatelessWidget {
  MyHome({super.key});

  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffedf0f1),
        body: Column(
          children: <Widget>[
            const Spacer(
              flex: 4,
            ),
            Container(
                width: 245,
                alignment: Alignment.centerRight,
                child: SvgPicture.asset(
                  'assets/images/splash.svg',
                  semanticsLabel: 'vector',
                )),
            const Spacer(),
            Container(
              height: 48,
              width: 213.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Color(0xff8d96b6), width: 3),
              ),
              child: TextButton(
                child: const Text("Войти",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Montserrat",
                      color: Color(0xff8d96b6),
                      fontWeight: FontWeight.bold,
                    )),
                onPressed: () {
                  prefs.then((SharedPreferences prefs) {
                    return prefs.getString('ipadress') ?? '81.23.108.42:53537';
                  }).then((value) {
                    if (value.isNotEmpty) {
                      global.uri = value;
                    }

                    if (kReleaseMode) {
                      if (global.uri.contains('Не задан') || global.uri.isEmpty) {
                        global.uri = '81.23.108.42:53537';
                      }
                    }

                    if (kDebugMode) {
                      if (global.uri.contains('Не задан') ||
                          global.uri.contains('81.23.108') ||
                          global.uri.isEmpty) {
                        global.uri = '192.168.1.33:90';
                      }
                    }
                    
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                  });
                },
              ),
            ),
            const Spacer(
              flex: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: Container(
                  alignment: Alignment.bottomRight,
                  child: const Text(
                    'Make \nEvrasia \nGreat \nAgain',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Color(0xff8d96b6),
                        fontFamily: 'Montserrat',
                        fontSize: 23.804527282714844,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w800,
                        height: 1.5 /*PERCENT not supported*/
                        ),
                  )),
            )
          ],
        ));
  }
}
