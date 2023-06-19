import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info/package_info.dart';
import 'package:restismob/models/localTypes/TextInputAlert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'package:restismob/global.dart' as global;

class SettingsR extends StatefulWidget {
  final bool canEdit;
  final TextStyle titleStyle = const TextStyle(
    fontSize: 18,
    fontFamily: "Montserrat",
    fontWeight: FontWeight.bold,
  );

  final TextStyle subtitleStyle = const TextStyle(
    fontSize: 14,
    fontFamily: "Montserrat",
    fontWeight: FontWeight.bold,
  );

  const SettingsR({super.key, required this.canEdit});

  @override
  State<SettingsR> createState() => SettingsRState();
}

class SettingsRState extends State<SettingsR> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _prefs.then((SharedPreferences prefs) {
      return prefs.getString('ipadress') ?? ' Не задан';
    }).then((value) {
      value.isNotEmpty ? global.uri = value : global.uri = ' Не задан';
      if (kReleaseMode) {
        if (global.uri.contains('Не задан') || global.uri.isEmpty) {
          global.uri = '81.23.108.42:53537';
        }
      }

      if (kDebugMode) {
        if (global.uri.contains('Не задан') ||
            global.uri.contains('81.23.108') ||
            global.uri.trim().isEmpty) {
          global.uri = '192.168.1.33:90';
        }
      }
    });
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Widget _infoTile(String title, String subtitle) {
    return ListTile(
      title: Text(
        title,
        style: widget.titleStyle,
      ),
      subtitle: Text(
        subtitle.isNotEmpty ? subtitle : 'Не установлено',
        style: widget.subtitleStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      backgroundColor: const Color(0xffC9CFDB),
      centerTitle: true,
      leading: InkWell(
        onTap: () {
          //global.navKey.currentState!.pop;
          Navigator.of(context).maybePop();
        },
        child: const Icon(
          Icons.arrow_back,
          color: Colors.white60,
        ),
      ),
      title: const Text(
        "Настройки",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Card(
              margin: const EdgeInsets.all(5), child: _infoTile('Версия приложения :', _packageInfo.version)),
          Card(
            margin: const EdgeInsets.all(5),
            child: ListTile(
              title: Text(
                'IP адрес',
                style: widget.titleStyle,
              ),
              subtitle: Text(
                (global.uri.contains('Не задан') ||
                    global.uri.contains('81.23.108') ||
                    global.uri.trim().isEmpty)
                ?'Не задан'
                :global.uri,
                style: widget.subtitleStyle,
              ),
              trailing: widget.canEdit
                  ? IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        showDialog(
                                context: context,
                                builder: (_) => const TextInputAlert(title: 'Введите адрес и порт'))
                            .then((value) => {
                                  if (value != null)
                                    {
                                      _prefs.then((SharedPreferences prefs) {
                                        prefs.setString('ipadress', value).then(
                                              (bool success) => global.uri = value,
                                            );
                                      }),
                                    },
                                  setState(() {}),
                                });
                      })
                  : const Text(''),
            ),
          ),
          const Spacer(
            flex: 2,
          ),
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: Container(
                  width: 245,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/evras.svg',
                    semanticsLabel: 'vector',
                  )),
            ),
          ),
          const Text(
            '2023',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xffC7C8D3),
                fontFamily: 'Montserrat',
                fontSize: 23.804527282714844,
                letterSpacing: 0,
                fontWeight: FontWeight.w400,
                height: 1.5 /*PERCENT not supported*/
                ),
          )
        ],
      ),
    );
  }
}
