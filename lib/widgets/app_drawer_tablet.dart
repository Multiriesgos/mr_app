import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/index.dart';

import '../services/storage_service.dart';
import '../views/product.dart';

class AppDrawerTabletPortrait extends StatefulWidget {
  final String nameu;

  const AppDrawerTabletPortrait({super.key, required this.nameu});

  @override
  State<AppDrawerTabletPortrait> createState() => _AppDrawerTabletPortraitState();
}

class _AppDrawerTabletPortraitState extends State<AppDrawerTabletPortrait> {
  final StorageService _storageService = StorageService();

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Salida'),
          content: const Text('¿Está seguro de que desea cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                await _storageService.deleteAllSecureData();
                if (mounted) {
                  context.goNamed('SecondScreen');
                }
              },
              child: const Text('Salir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawerHeight = MediaQuery.of(context).size.height * 0.12;
    return Container(
      height: drawerHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 16, color: Colors.black12),
        ],
      ),
      child: Scaffold(
        bottomNavigationBar: Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 30.0, top: 10.0),
            ),
            SizedBox(
              height: drawerHeight,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                  child: Column(
                    children: <Widget>[
                      const Icon(
                        Icons.person_pin,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      Text(
                        widget.nameu,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15.0),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 20.0),
            ),
            SizedBox(
              height: drawerHeight,
              child: InkWell(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Product())),
                child: const Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 20.0),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.list_alt,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      Text(
                        'Mis Productos',
                        style: TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 20.0),
            ),
            SizedBox(
              height: drawerHeight,
              child: InkWell(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const MyCardsWidget())),
                child: const Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 20.0),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.card_giftcard,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      Text(
                        'Beneficios',
                        style: TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 20.0),
            ),
            SizedBox(
              height: drawerHeight,
              child: InkWell(
                onTap: () => _logout(),
                child: const Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 20.0),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.exit_to_app_sharp,
                        size: 40.0,
                        color: Colors.red,
                      ),
                      Text(
                        'Salir',
                        style: TextStyle(color: Colors.red, fontSize: 15.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromRGBO(23, 0, 147, 1),
      ),
    );
  }
}

class AppDrawerTabletLandscape extends StatefulWidget {
  final String nameu;

  const AppDrawerTabletLandscape({super.key, required this.nameu});

  @override
  State<AppDrawerTabletLandscape> createState() => _AppDrawerTabletLandscapeState();
}

class _AppDrawerTabletLandscapeState extends State<AppDrawerTabletLandscape> {
  final StorageService _storageService = StorageService();

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Salida'),
          content: const Text('¿Está seguro de que desea cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                await _storageService.deleteAllSecureData();
                if (mounted) {
                  context.goNamed('SecondScreen');
                }
              },
              child: const Text('Salir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth = MediaQuery.of(context).size.width * 0.22;
    return Container(
      width: drawerWidth,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 16, color: Colors.black12),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xff170093),
            ),
            accountName: Text(
              widget.nameu,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              radius: 40.0,
              backgroundColor: Color(0xffffffff),
              backgroundImage: AssetImage('assets/images/7_fit.png'),
            ),
            accountEmail: null,
          ),
          ListTile(
            leading: const Icon(Icons.account_box),
            title: Transform.translate(
              offset: const Offset(-16, 0),
              child: const Text("Mis Productos"),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const Product()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: Transform.translate(
              offset: const Offset(-16, 0),
              child: const Text("Mis Beneficios"),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const MyCardsWidget()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app_sharp, color: Colors.red),
            title: Transform.translate(
              offset: const Offset(-16, 0),
              child: const Text(
                "Salir",
                style: TextStyle(color: Colors.red),
              ),
            ),
            onTap: () {
              _logout();
            },
          )
        ],
      ),
    );
  }
}
