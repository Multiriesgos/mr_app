import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/storage_service.dart';
import '../ui/orientation_layout.dart';
import '../ui/screen_type_layout.dart';
import 'app_drawer_mobile.dart';
import 'app_drawer_tablet.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  AppDrawer2 createState() => AppDrawer2();
}

class AppDrawer2 extends State<AppDrawer> {
  final StorageService _storageService = StorageService();
  String nameu = "";

  Future<String> _readFromStorage() async {
    final String xnameu = await _storageService.readSecureData('KEY_NAME') ?? "";
    //debugPrint("app_drawer xnameu= $xnameu");
    return xnameu;
  }

  @override
  void initState() {
    super.initState();
    _readFromStorage().then((value) {
      setState(() {
        nameu = value;
      });
    });
    //debugPrint("app_drawer nameu= $nameu");
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    return ScreenTypeLayout(
      mobile: AppDrawerMobileLayout(
        nameu: nameu,
      ),
      tablet: OrientationLayout(
        portrait: AppDrawerTabletPortrait(
          nameu: nameu,
        ),
        landscape: AppDrawerTabletLandscape(
          nameu: nameu,
        ),
      ),
    );
  }
}
