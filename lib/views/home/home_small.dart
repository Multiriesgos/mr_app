import 'package:flutter/material.dart';
import 'package:mr_app/main.dart';
import 'package:mr_app/widgets/app_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mr_app/services/storage_service.dart';
import 'package:mr_app/circle_painter.dart';
import 'package:mr_app/curve_wave.dart';
import 'package:mr_app/custom_drawer/home_drawer.dart';

import '../../theme/fintech_theme.dart';

_makingPhonecall() async {
  var url = Uri.parse('tel:+50322600202');
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'No puede llamarse a $url en este momento';
  }
}

class HomePage extends StatefulWidget {
  final String uname;
  final String name1;

  const HomePage({
    super.key,
    required this.uname,
    this.size = 80.0,
    this.color = const Color.fromRGBO(23, 0, 147, 1),
    required this.name1,
    required this.child,
    required this.onPressed,
  });
  final double size;
  final Color color;
  final Widget? child;
  final VoidCallback onPressed;

  @override
  State<StatefulWidget> createState() {
    return HomePageView();
  }
}

class HomePageView extends State<HomePage> with TickerProviderStateMixin {
  String _uname = "", name1 = "";
  late AnimationController _controller;
  late Widget screenView;
  late DrawerIndex drawerIndex;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _readFromStorage() async {
    final storageService = StorageService();
    _uname = await storageService.readSecureData('KEY_USERNAME') ?? '';
    name1 = await storageService.readSecureData('KEY_NAME1') ?? '';
    _uname = _uname.toUpperCase();
    if (_uname == '') {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (ctx) => const SecondScreen(
                item: null,
                title: '',
              )));
    }
    setState(() {});
  }

  @override
  void initState() {
    _readFromStorage();
    drawerIndex = DrawerIndex.home;
    screenView = HomePage(
      uname: '',
      name1: '',
      onPressed: () {},
      child: null,
    );
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _button() {
    return Center(
      child: GestureDetector(
        onTap: _makingPhonecall,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.size),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: <Color>[
                  widget.color,
                  Color.lerp(widget.color, Colors.white, .05)!
                ],
              ),
            ),
            child: ScaleTransition(
                scale: Tween(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const CurveWave(),
                  ),
                ),
                child: const Icon(
                  Icons.speaker_phone,
                  size: 44,
                  color: Colors.white,
                )),
          ),
        ),
      ),
    );
  }

  /// Calcula el tamaño del botón de llamada de forma responsiva
  /// Limita el tamaño máximo al 60% del ancho de pantalla, con máximo de 250px
  double _calculateButtonSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final calculatedSize = widget.size * 3.125; // 80 * 3.125 = 250
    final maxSize = screenWidth * 0.60; // 60% del ancho de pantalla

    return calculatedSize > maxSize ? maxSize : calculatedSize;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: FinTechTheme.of(context).secondaryBackground,
        /*appBar: AppBar(
        title: const Text('Cliente Multiriesgos'),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromRGBO(23, 0, 147, 1),
        elevation: 1,
      ),*/
        drawer: const AppDrawer(),
        body: SafeArea(
            child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                    child: SingleChildScrollView(
                      primary: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 10, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 10, 0),
                                  child: InkWell(
                                      onTap: () {
                                        if (scaffoldKey
                                            .currentState!.isDrawerOpen) {
                                          scaffoldKey.currentState!
                                              .openEndDrawer();
                                        } else {
                                          scaffoldKey.currentState!
                                              .openDrawer();
                                        }
                                      },
                                      child: const Icon(
                                        Icons.menu,
                                        size: 30,
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 4, 0, 0),
                                  child: Text(
                                    'Cliente Multiriesgos',
                                    style: FinTechTheme.of(context)
                                        .bodyText1
                                        .override(
                                          fontFamily: 'Inter',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Column(
                              children: [
                                Container(height: size.height * .045),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0,
                                      left: 30.0,
                                      right: 30.0,
                                      bottom: 30.0),
                                  child: Image.asset(
                                    'assets/images/5_fit.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  height: size.height * .045,
                                ),
                                Text(
                                  'Bienvenido(a) $name1',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  height: size.height * .025,
                                ),
                                const Text(
                                  'Llamar a MULTIRIESGOS',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  height: size.height * .025,
                                ),
                                Center(
                                  child: CustomPaint(
                                    painter: CirclePainter(
                                      _controller,
                                      color: widget.color,
                                    ),
                                    child: SizedBox(
                                      width: _calculateButtonSize(context),
                                      height: _calculateButtonSize(context),
                                      child: _button(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )))));
  }
}
