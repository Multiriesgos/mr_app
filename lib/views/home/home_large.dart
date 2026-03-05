import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mr_app/main.dart';
import 'package:mr_app/widgets/app_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mr_app/services/storage_service.dart';
import 'package:mr_app/circle_painter.dart';
import 'package:mr_app/curve_wave.dart';
import 'package:mr_app/custom_drawer/home_drawer.dart';


_makingPhonecall() async {
  var url = Uri.parse('tel:+50322600202');
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'No puede llamarse a $url en este momento';
  }
}

class HomePageLarge extends StatefulWidget {
  final String uname;
  final String name1;

  const HomePageLarge({
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
    return HomePageLargeView();
  }
}

class HomePageLargeView extends State<HomePageLarge>
    with TickerProviderStateMixin {
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
    screenView = HomePageLarge(
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
  /// Limita el tamaño máximo al 25% del ancho de pantalla en landscape
  double _calculateButtonSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final calculatedSize = widget.size * 2.125; // 80 * 2.125 = 170
    final maxSize = screenWidth * 0.25; // 25% en landscape

    return calculatedSize > maxSize ? maxSize : calculatedSize;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    var size = MediaQuery.of(context).size;
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Cliente Multiriesgos'),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromRGBO(23, 0, 147, 1),
        elevation: 1,
      ),*/
      body: SafeArea(
          child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  child: Row(
                    children: <Widget>[
                      const Expanded(flex: 2, child: AppDrawer()),
                      Expanded(
                          flex: 4,
                          child: SingleChildScrollView(
                            child: Center(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0.0,
                                        left: 0.0,
                                        right: 10.0,
                                        bottom: 0.0),
                                    child: Image.asset(
                                      'assets/images/5_fit.png',
                                      fit: BoxFit.fill,
                                      height: size.height * 0.20,
                                      width: size.width * 0.40,
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
                                ],
                              ),
                            ),
                          )),
                      Expanded(
                          flex: 3,
                          child: Center(
                            child: Column(children: [
                              Container(
                                height: size.height * .250,
                              ),
                              const Text(
                                'Llamar MULTIRIESGOS',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
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
                            ]),
                          )),
                    ],
                  )))),
    );
  }
}
