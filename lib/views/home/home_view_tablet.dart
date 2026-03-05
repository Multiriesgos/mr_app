import 'package:flutter/material.dart';

import '../../widgets/app_drawer.dart';
import 'home_tablet.dart';

class HomeTablet extends StatelessWidget {
  final String nameu;

  const HomeTablet({super.key, required this.nameu});

  @override
  Widget build(BuildContext context) {
    var children = [
      Expanded(
        child: HomePageTablet(
          uname: '',
          name1: '',
          onPressed: () {},
          child: null,
        ),
      ),
      const AppDrawer()
    ];
    var orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      body: orientation == Orientation.portrait
          ? Column(
              children: children,
            )
          : Row(
              children: children.reversed.toList(),
            ),
    );
  }
}
