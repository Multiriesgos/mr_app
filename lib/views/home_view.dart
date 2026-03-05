import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mr_app/views/home/home_large.dart';
import 'package:mr_app/views/home/home_small.dart';

import '../services/storage_service.dart';
import '../ui/orientation_layout.dart';
import '../ui/screen_type_layout.dart';
import 'home/home_view_tablet.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => HomeView2();
}

class HomeView2 extends State<HomeView> {
  final StorageService _storageService = StorageService();
  String nameu = "";

  Future<String> _readFromStorage() async {
    final String xnameu = (await _storageService.readSecureData('KEY_NAME'))!;
    //debugPrint("home_view xnameu= $xnameu");
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
    //debugPrint("home_view nameu= $nameu");
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
      mobile: OrientationLayout(
        portrait: HomePage(
          uname: nameu.toString(),
          name1: '',
          onPressed: () {},
          child: null,
        ),
        landscape: HomePageLarge(
          uname: nameu.toString(),
          name1: '',
          onPressed: () {},
          child: null,
        ),
      ),
      tablet: HomeTablet(
        nameu: nameu.toString(),
      ),
    );
  }
}
