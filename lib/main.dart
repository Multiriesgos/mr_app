import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mr_app/models/storage_item.dart';
import 'package:mr_app/profile/profile_widget.dart';
import 'package:mr_app/services/storage_service.dart';
import 'package:mr_app/transactions/transactions_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home/home_widget.dart';
import 'my_cards/my_cards_widget.dart';
import 'theme/fintech_theme.dart';
import 'theme/fintech_util.dart';
import 'theme/internationalization.dart';
import 'theme/nav/nav.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Configurar Google Fonts para no descargar en runtime (usar fuentes bundled)
  GoogleFonts.config.allowRuntimeFetching = false;

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(const MyApp()));
  //runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  bool displaySplashImage = false;

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier();
    _router = createRouter(_appStateNotifier);

    Future.delayed(const Duration(seconds: 1),
        () => setState(() => _appStateNotifier.stopShowingSplashImage()));
  }

  void setLocale(String language) =>
      setState(() => _locale = createLocale(language));

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 Pro design base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        title: 'Bienvenido',
        localizationsDelegates: const [
          FFLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: _locale,
        supportedLocales: const [Locale('en', '')],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        themeMode: _themeMode,
        routerConfig: _router,
        //routeInformationParser: _router.routeInformationParser,
        //routerDelegate: _router.routerDelegate,
        //home: const Splash2(),
      ),
    );
  }
}

class Splash2 extends StatefulWidget {
  const Splash2({super.key});

  @override
  Splash2x createState() => Splash2x();
}

class Splash2x extends State<Splash2> with SingleTickerProviderStateMixin {
  var _visible = true;

  late AnimationController animationController;
  late Animation<double> animation;

  startTime() async {
    var duration = const Duration(seconds: 4);
    return Timer(duration, navigationPage);
  }

  void navigationPage() {
    context.goNamed('SecondScreen');
  }

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });

    startTime();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
          const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 30.0),
                child: Text(
                  'MULTIRIESGOS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/7_fit.png',
                width: animation.value * 350,
                height: animation.value * 350,
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  final StorageItem? item;

  const SecondScreen({super.key, required this.title, required this.item});
  final String title;

  @override
  MySecondScreenState createState() => MySecondScreenState();
}

class MySecondScreenState extends State<SecondScreen> {
  bool _visible = false;
  bool _savePassword = true;
  bool _isLoading = false;

  final StorageService _storageService = StorageService();

  final userController = TextEditingController();
  final pwdController = TextEditingController();
  String nombreController = "";
  String docsearch = "";

  Future userLogin() async {
    //Uri url = Uri.parse('https://api.multiriesgos.com/user_login.php');
    //Uri url = Uri.parse('https://secure.multiriesgos.com/api/user/name/');
    String uriPlus = '/api/user/name/${userController.text}';
    Uri url = Uri.https('secure.multiriesgos.com', uriPlus);
    //Uri url = Uri.https('secure.multiriesgos.com', uri_plus);

    setState(() {
      _visible = true;
      _isLoading = true;
    });

    var response = await http.post(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'MRApiKey':
          'MultimateBSaWxylfSeUygBjm4fSb80UDnwkSkVdGHpa1ZW1ogldMfE6fNFpPwWqBTUVZy3ngB5oUckGVOIRBmmps2NAd2BGKamsDW6bLP6aNEfxKxlAGK1rZWUBFwF6'
    });
    if (response.statusCode == 200) {
      //print(response.body);
      var msg = jsonDecode(response.body);

      // Validar que los campos requeridos no sean null
      final userappPass = msg['userapp_pass'];
      final userappUser = msg['userapp_user'];
      final userappEmail = msg['userapp_correo'];
      final userappNombre = msg['userapp_nombre'];
      final userappNombre1 = msg['userapp_nombre1'];
      final userappDocSearch = msg['userapp_docsearch'];

      // Verificar campos null o valores inválidos
      if (userappPass == null || userappUser == null ||
          userappEmail == null || userappNombre == null ||
          userappNombre1 == null || userappDocSearch == null) {
        setState(() {
          _visible = false;
          _isLoading = false;
        });
        showMessage("Error: Datos incompletos del servidor. Intente de nuevo.");
        return;
      }

      if (userappPass == pwdController.text) {
        setState(() {
          _visible = false;
          _isLoading = true;
        });
        nombreController = userappUser;
        // aca vamos a guardar las credenciales
        _storageService
            .writeSecureData(StorageItem("KEY_USERNAME", userappUser));
        _storageService
            .writeSecureData(StorageItem("KEY_PASSWORD", userappPass));
        _storageService
            .writeSecureData(StorageItem("KEY_EMAIL", userappEmail));
        _storageService
            .writeSecureData(StorageItem("KEY_NAME", userappNombre));
        _storageService
            .writeSecureData(StorageItem("KEY_NAME1", userappNombre1));
        _storageService.writeSecureData(
            StorageItem("KEY_SEARCH", userappDocSearch));
        _storageService.writeSecureData(
            StorageItem("KEY_REMIND", _savePassword.toString()));
        if (!mounted) return;
        context.goNamed('HomeView');
      } else {
        setState(() {
          _visible = false;
          _isLoading = false;
          showMessage("Credenciales no validas.");
        });
      }
    } else {
      setState(() {
        _visible = false;
        _isLoading = false;
        showMessage("Credenciales no validas.");
        //showMessage("Error durante la conexion al servidor");
      });
    }
  }

  Future<dynamic> showMessage(String msg) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      margin: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 20),
      duration: const Duration(seconds: 4),
      content: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 0,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Oops Error!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          height: 1.4,
                        ),
                        maxLines: null,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              top: -18,
              left: 16,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),
                  ),
                  const Icon(
                    Icons.clear_outlined,
                    color: Colors.white,
                    size: 22,
                  )
                ],
              )),
        ],
      ),
    ));
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _readFromStorage() async {
    userController.text =
        await _storageService.readSecureData('KEY_USERNAME') ?? '';
    pwdController.text =
        await _storageService.readSecureData('KEY_PASSWORD') ?? '';
    String valor =
        await _storageService.readSecureData('KEY_REMIND') ?? 'false';
    setState(() {
      _savePassword = valor.parseBool();
      if (!_savePassword) {
        userController.text = '';
        pwdController.text = '';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _readFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    var size = MediaQuery.of(context).size;
    return Center(
        child: Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Visibility(
              visible: _visible,
              child: Container(
                margin: const EdgeInsets.only(bottom: 25.0),
                child: const LinearProgressIndicator(),
              ),
            ),
            Container(height: size.height * .115),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 30.0, left: 30.0, right: 30.0, top: 15.0),
              child: Image.asset(
                'assets/images/5_fit.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: (size.height * .025),
            ),
            const Text(
              'INGRESE AQUI',
              style: TextStyle(
                  color: Color.fromRGBO(23, 0, 147, 1),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: (size.height * .045),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Column(
                  children: [
                    Theme(
                      data: ThemeData(
                        primaryColor: const Color.fromRGBO(84, 87, 90, 0.5),
                        primaryColorDark: const Color.fromRGBO(84, 87, 90, 0.5),
                        hintColor: const Color.fromRGBO(
                            84, 87, 90, 0.5), //placeholder color
                      ),
                      child: TextFormField(
                        controller: userController,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(84, 87, 90, 0.5),
                              style: BorderStyle.solid,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(84, 87, 90, 0.5),
                              style: BorderStyle.solid,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                          labelText: 'No. Documento',
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color.fromRGBO(84, 87, 90, 0.5),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(84, 87, 90, 0.5),
                              style: BorderStyle.solid,
                            ),
                          ),
                          hintText: 'Digite numero documento',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese número documento';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: (size.height * .025),
                    ),
                    Theme(
                      data: ThemeData(
                        primaryColor: const Color.fromRGBO(84, 87, 90, 0.5),
                        primaryColorDark: const Color.fromRGBO(84, 87, 90, 0.5),
                        hintColor: const Color.fromRGBO(
                            84, 87, 90, 0.5), //placeholder color
                      ),
                      child: TextFormField(
                        inputFormatters: [
                          MaskTextInputFormatter(
                            mask: "##/##/####",
                          ),
                        ],
                        controller: pwdController,
                        maxLength: 10,
                        keyboardType: TextInputType.datetime,
                        obscureText: false,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(84, 87, 90, 0.5),
                              style: BorderStyle.solid,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(84, 87, 90, 0.5),
                              style: BorderStyle.solid,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(84, 87, 90, 0.5),
                              style: BorderStyle.solid,
                            ),
                          ),
                          labelText: 'Fecha de nacimiento',
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Color.fromRGBO(84, 87, 90, 0.5),
                          ),
                          hintText: 'dd/mm/yyyy',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite fecha de nacimiento';
                          }
                          if (value.length != 10) {
                            return 'Digite fecha en formato DD/MM/YYYY';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: size.height * .025,
                    ),
                    CheckboxListTile(
                      value: _savePassword,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _savePassword = newValue!;
                        });
                      },
                      title: const Text('Recordar cliente'),
                      activeColor: const Color.fromRGBO(23, 0, 147, 1),
                    ),
                    SizedBox(
                      height: (size.height * .025),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ElevatedButton.icon(
                                  icon: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Icon(Icons.shopping_cart),
                                  onPressed: () => {
                                    // Validate returns true if the form is valid, or false otherwise.
                                    _launchURL()
                                  },
                                  label: const Text(
                                    'COTIZA',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 56),
                                      backgroundColor: Colors.orange),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ElevatedButton.icon(
                                  icon: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Icon(Icons.key),
                                  onPressed: () => {
                                    // Validate returns true if the form is valid, or false otherwise.
                                    if (_formKey.currentState!.validate())
                                      {_isLoading ? null : userLogin()}
                                  },
                                  label: const Text(
                                    'INGRESAR',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 56)),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ),
    ));
  }
}

extension BoolParsing on String {
  bool parseBool() {
    if (toLowerCase() == 'true') {
      return true;
    } else if (toLowerCase() == 'false') {
      return false;
    }

    throw '"$this" can not be parsed to boolean.';
  }
}

class NavBarPage extends StatefulWidget {
  const NavBarPage({super.key, this.initialPage, this.page});

  final String? initialPage;
  final Widget? page;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'Home';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'Home': const HomeWidget(),
      'MyCards': const MyCardsWidget(),
      'Transactions': const TransactionsWidget(),
      'Profile': const ProfileWidget(),
    };
    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);
    return Scaffold(
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() {
          _currentPage = null;
          _currentPageName = tabs.keys.toList()[i];
        }),
        backgroundColor: Colors.white,
        selectedItemColor: FinTechTheme.of(context).primaryColor,
        unselectedItemColor: const Color(0x8A000000),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_filled,
              size: 24,
            ),
            label: '',
            tooltip: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.credit_card_outlined,
              size: 24,
            ),
            label: '',
            tooltip: 'Mis beneficios',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.compare_arrows_rounded,
              size: 24,
            ),
            label: '',
            tooltip: 'Transacciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu_rounded,
              size: 24,
            ),
            label: '',
            tooltip: 'Perfil',
          )
        ],
      ),
    );
  }
}

_launchURL() async {
  final Uri url = Uri.parse("https://multiriesgos.com/cotizador");
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw Exception('No podemos llegar a $url');
  }
}
