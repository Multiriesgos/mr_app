import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mr_app/models/cab_item.dart';
import 'package:mr_app/models/ren_item.dart';
import 'package:mr_app/services/webservice.dart';
import 'package:mr_app/utils/helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/fintech_theme.dart';

class Ver extends StatefulWidget {
  final int idRen;

  const Ver({super.key, required this.idRen});

  @override
  VerPage createState() => VerPage(idRen: idRen);
}

_makePhoneCall(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'No puede llamarse a $url en este momento';
  }
}

openwhatsapp(BuildContext context, String url) async {
  var whatsapp = "+503$url";
  Uri whatsappurlAndroid =
      Uri.parse("whatsapp://send?phone=$whatsapp&text=Hola");
  Uri whatappurlIos = Uri.parse("https://wa.me/$whatsapp?text=Hola");
  if (Platform.isIOS) {
    // for iOS phone only
    if (await canLaunchUrl(whatappurlIos)) {
      await launchUrl(whatappurlIos);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("whatsapp no installed")));
    }
  } else {
    // android , web
    if (await canLaunchUrl(whatsappurlAndroid)) {
      await launchUrl(whatsappurlAndroid);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("whatsapp no installed")));
    }
  }
}

class VerPage extends State<Ver> {
  RenItem item = RenItem();
  CabItem cabina = CabItem();
  int idRen;

  VerPage({required this.idRen});

  bool isVisiblePhone = false;
  bool isVisibleWhastApp = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _populateRenovacion();
  }

  void _populateRenovacion() {
    Future.delayed(Duration.zero, () async {
      LoadingIndicatorDialog().show(context);
    });
    Webservice().find(RenItem.one(idRen)).then((newsArticles) {
      setState(() {
        item = newsArticles;
        Webservice()
            .loadCab(CabItem.one(item.aseguradora, item.ramo, item.tipoSeguro))
            .then((newsCab) {
          setState(() {
            cabina = newsCab;
            if (cabina.cabina != null) {
              setState(() {isVisiblePhone = true;});
            }
            if (cabina.whatsapp != null) {
              setState(() {isVisibleWhastApp = true;});
            }
          });
        });
        LoadingIndicatorDialog().dismiss();
      });
    }).catchError((error) {
      LoadingIndicatorDialog().dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FinTechTheme.of(context).primaryBackground,
      /*appBar: AppBar(
        title: const Text(
          'Detalle de Poliza',
          style: TextStyle(fontSize: 20.0),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color.fromRGBO(23, 0, 147, 1),
        elevation: 1,
      ),*/
      body: SafeArea(
          child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                  child: SingleChildScrollView(
                    primary: false,
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 10, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        //context.replaceNamed('Product');
                                        context.pop();
                                      },
                                      child: const Icon(
                                        Icons.arrow_back_sharp,
                                        color: Colors.black,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              5, 0, 0, 0),
                                      child: Text(
                                        'Detalle de producto',
                                        style: FinTechTheme.of(context)
                                            .bodyText1
                                            .override(
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
                                  children: [],
                                ),
                              ],
                            ),
                          ),
                          const Column(children: <Widget>[
                            Padding(
                                padding:
                                    EdgeInsets.only(top: 20.0, bottom: 20.0),
                                child: Text(
                                  'Contacto Cabina',
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w700,
                                      color: Color.fromRGBO(64, 105, 225, 1)),
                                ))
                          ]),
                          const Center(
                              child: InkWell(
                            child: CircleAvatar(
                              radius: 65,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                backgroundImage: AssetImage(
                                  'assets/images/7_fit.png',
                                ),
                                radius: 60,
                              ),
                            ),
                          )),
                          buildUserInfoDisplay(
                              '${item.aseguradora}', 'ASEGURADORA'),
                          buildUserInfoDisplay('${item.ramo}', 'RAMO'),
                          buildUserInfoDisplay(
                              '${item.tipoSeguro}', 'TIPO SEGURO'),
                          buildUserInfoDisplay(
                              '${item.asegurado}', 'ASEGURADO'),
                          buildUserInfoDisplay('${item.adjunto}', 'POLIZA'),
                          Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                isVisiblePhone
                                    ? Container(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Ink(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.blue,
                                                          width: 2),
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0)), //<-- SEE HERE
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100.0),
                                                    onTap: () {
                                                      var url = Uri.parse(
                                                          'tel:+503${cabina.cabina}');
                                                      setState(() {
                                                        _makePhoneCall(url);
                                                      });
                                                    },
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(10.0),
                                                      child: Icon(
                                                        Icons
                                                            .phone_enabled_outlined,
                                                        size: 50.0,
                                                        color:
                                                            Colors.blueAccent,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Text(
                                                  'Cabina',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.0),
                                                ),
                                              ]),
                                        ))
                                    : Container(),
                                isVisibleWhastApp
                                    ? Container(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Ink(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.green,
                                                          width: 2),
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0)), //<-- SEE HERE
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100.0),
                                                    onTap: () {
                                                      openwhatsapp(context,
                                                          cabina.whatsapp);
                                                    },
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(10.0),
                                                      child: FaIcon(
                                                        FontAwesomeIcons
                                                            .whatsapp,
                                                        size: 50.0,
                                                        color:
                                                            Colors.greenAccent,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Text(
                                                  'WhatsApp',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.0),
                                                )
                                              ]),
                                        ))
                                    : Container(),
                              ]),
                        ]),
                  )))),
    );
  }

  Widget buildUserInfoDisplay(String getValue, String title) => Center(
    child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
            ),
            const SizedBox(
              height: 1,
            ),
            Container(
              width: 350,
              height: 40,
              decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey, width: 1))),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      getValue == "null" ? 'no disponible' : getValue,
                      style: const TextStyle(
                          fontSize: 16.0,
                          height: 1,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ));

  // Widget builds the About Me Section
  Widget buildAbout(String user) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell Us About Yourself',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 1),
          Container(
              width: 350,
              height: 200,
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                color: Colors.grey,
                width: 1,
              ))),
              child: Row(children: [
                Expanded(
                    child: TextButton(
                        onPressed: () {},
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  user,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                ))))),
                const Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.grey,
                  size: 40.0,
                )
              ]))
        ],
      ));
}
