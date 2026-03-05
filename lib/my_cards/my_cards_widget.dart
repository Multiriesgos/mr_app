import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/storage_service.dart';
import '../theme/fintech_theme.dart';
import 'package:flutter/material.dart';


class MyCardsWidget extends StatefulWidget {
  const MyCardsWidget({super.key});

  @override
  _MyCardsWidgetState createState() => _MyCardsWidgetState();
}

class _MyCardsWidgetState extends State<MyCardsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final StorageService _storageService = StorageService();
  String nameu = "", useru = "", searchu = "";

  Future<String> _readFromStorage() async {
    final String xnameu = (await _storageService.readSecureData('KEY_NAME'))!;
    //debugPrint("home_view xnameu= $xnameu");
    return xnameu;
  }

  Future<String> _readFromStorageU() async {
    final String xuseru =
        (await _storageService.readSecureData('KEY_USERNAME'))!;
    return xuseru;
  }

  Future<String> _readFromStorageS() async {
    final String xsearchu =
        (await _storageService.readSecureData('KEY_SEARCH'))!;
    return xsearchu;
  }

  @override
  void initState() {
    super.initState();
    _readFromStorage().then((value) {
      setState(() {
        nameu = value;
      });
    });
    _readFromStorageU().then((value) {
      setState(() {
        useru = value;
      });
    });
    _readFromStorageS().then((value) {
      setState(() {
        searchu = value;
      });
    });
    //debugPrint("home_view nameu= $nameu");
  }

  _launchMedic() async {
    const url = "https://medic.com.sv";
    final Uri url0 = Uri.parse(url);
    if (await canLaunchUrl(url0)) {
      await launchUrl(url0, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchClubahorro() async {
    const url = "https://clubahorro.sv";
    final Uri url0 = Uri.parse(url);
    if (await canLaunchUrl(url0)) {
      await launchUrl(url0, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchCarnet(String dui) async {
    String url = "http://afiliados.multiassist.net/click.php?i=$dui";
    final Uri url0 = Uri.parse(url);
    if (await canLaunchUrl(url0)) {
      await launchUrl(url0, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FinTechTheme.of(context).secondaryBackground,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 25),
            child: SingleChildScrollView(
              primary: false,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () async {
                                //context.replaceNamed('HomeView');
                                context.pop();
                              },
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  5, 0, 0, 0),
                              child: Text(
                                'Mis beneficios',
                                style:
                                    FinTechTheme.of(context).bodyText1.override(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                        ),
                              ),
                            ),
                          ],
                        ),
                        const Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [],
                        ),
                      ],
                    ),
                  ),
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0, 25, 20, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tu carnet',
                                    style: FinTechTheme.of(context)
                                        .bodyText1
                                        .override(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                    child: InkWell(
                      onTap: () async {
                        _launchCarnet(searchu);
                        //context.pushNamed('MyCardsInfo');
                      },
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? MediaQuery.of(context).size.height * 0.25
                            : MediaQuery.of(context).size.height * 0.35,
                        decoration: BoxDecoration(
                          color: FinTechTheme.of(context).secondaryBackground,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: Image.asset(
                              'assets/images/Card-bg-1.png',
                            ).image,
                          ),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              MediaQuery.of(context).size.width * 0.08,
                              MediaQuery.of(context).size.height * 0.03,
                              MediaQuery.of(context).size.width * 0.08,
                              MediaQuery.of(context).size.height * 0.03),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    MediaQuery.of(context).orientation ==
                                            Orientation.portrait
                                        ? MediaQuery.of(context).size.width * 0.12
                                        : MediaQuery.of(context).size.width * 0.32,
                                    MediaQuery.of(context).orientation ==
                                            Orientation.portrait
                                        ? MediaQuery.of(context).size.height * 0.025
                                        : MediaQuery.of(context).size.height * 0.045,
                                    0,
                                    0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      nameu,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: FinTechTheme.of(context)
                                          .bodyText1
                                          .override(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    MediaQuery.of(context).orientation ==
                                            Orientation.portrait
                                        ? MediaQuery.of(context).size.width * 0.07
                                        : MediaQuery.of(context).size.width * 0.18,
                                    MediaQuery.of(context).orientation ==
                                            Orientation.portrait
                                        ? MediaQuery.of(context).size.height * 0.005
                                        : MediaQuery.of(context).size.height * 0.008,
                                    0,
                                    0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      useru,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: FinTechTheme.of(context)
                                          .bodyText1
                                          .override(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontSize: 16,
                                            letterSpacing: 1.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0, 25, 20, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tu red medica',
                              style: FinTechTheme.of(context)
                                  .bodyText1
                                  .override(
                                fontFamily: 'Inter',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                      : Container(),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                    child: InkWell(
                      onTap: () async {
                        _launchMedic();
                        //context.pushNamed('MyCardsInfo');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            //<-- SEE HERE
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          'assets/images/logo_medic.jpg',
                          width: double.infinity,
                          height: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? 112
                              : 250,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0, 25, 20, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tu red de ahorro',
                              style: FinTechTheme.of(context)
                                  .bodyText1
                                  .override(
                                fontFamily: 'Inter',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                      : Container(),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                    child: InkWell(
                      onTap: () async {
                        _launchClubahorro();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            //<-- SEE HERE
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          'assets/images/logo_clubahorroblanco.png',
                          width: double.infinity,
                          height: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? 112
                              : 250,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
