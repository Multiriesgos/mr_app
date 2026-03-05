import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/index.dart';

import '../services/storage_service.dart';
import '../views/product.dart';

class AppDrawerMobileLayout extends StatefulWidget {
  final String nameu;

  const AppDrawerMobileLayout({super.key, required this.nameu});

  @override
  State<AppDrawerMobileLayout> createState() => _AppDrawerMobileLayoutState();
}

class _AppDrawerMobileLayoutState extends State<AppDrawerMobileLayout> {
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    return OrientationBuilder(
      builder: (context, orientation) {
        final drawerWidth = MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width * 0.75  // 75% en portrait
            : MediaQuery.of(context).size.width * 0.45; // 45% en landscape

        return Container(
          width: drawerWidth,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                color: Colors.black12,
              )
            ],
          ),
          child: ListView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                  width: drawerWidth,
                  child: UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xff170093),
                  ),
                  accountName: Text(
                    widget.nameu
                        .split(" ")
                        .sublist(0, 1)
                        .toString()
                        .replaceAll("[", "")
                        .replaceAll("]", ""),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  currentAccountPicture: const CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Color(0xffffffff),
                    backgroundImage: AssetImage('assets/images/7_fit.png'),
                  ),
                  accountEmail: null,
                )),
            SizedBox(
                width: drawerWidth,
                child: ListTile(
                  leading: Icon(
                    Icons.account_box,
                    size: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 30
                        : 50,
                  ),
                  title:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? Transform.translate(
                              offset: const Offset(-16, 0),
                              child: const Text("Mis Productos"),
                            )
                          : Transform.translate(
                              offset: const Offset(-16, 0),
                              child: const Text("Productos"),
                            ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Product()));
                  },
                )),
            SizedBox(
                width: drawerWidth,
                child: ListTile(
                  leading: Icon(
                    Icons.card_giftcard,
                    size: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 30
                        : 50,
                  ),
                  title:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? Transform.translate(
                              offset: const Offset(-16, 0),
                              child: const Text("Beneficios"),
                            )
                          : Transform.translate(
                              offset: const Offset(-16, 0),
                              child: const Text("Beneficios"),
                            ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const MyCardsWidget()));
                  },
                )),
            const Divider(),
            SizedBox(
                width: drawerWidth,
                child: ListTile(
                  leading: Icon(
                    Icons.exit_to_app_sharp,
                    size: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 30
                        : 50,
                    color: Colors.red,
                  ),
                  title:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? Transform.translate(
                              offset: const Offset(-16, 0),
                              child: const Text(
                                "Salir",
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          : Transform.translate(
                              offset: const Offset(-16, 0),
                              child: const Text(
                                "Salir",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                  onTap: () {
                    _logout();
                  },
                ))
          ],
          ),
        );
      },
    );
  }
}
