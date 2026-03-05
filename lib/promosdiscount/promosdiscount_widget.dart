import 'package:go_router/go_router.dart';

import '../theme/fintech_theme.dart';
import 'package:flutter/material.dart';

class PromosdiscountWidget extends StatefulWidget {
  const PromosdiscountWidget({super.key});

  @override
  _PromosdiscountWidgetState createState() => _PromosdiscountWidgetState();
}

class _PromosdiscountWidgetState extends State<PromosdiscountWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FinTechTheme.of(context).primaryBackground,
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
                          children: [
                            InkWell(
                              onTap: () async {
                                context.replaceNamed('HomeView');
                              },
                              child: const Icon(
                                Icons.arrow_back_sharp,
                                color: Colors.black,
                                size: 24,
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
                                  const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                              child: Text(
                                'Promociones y descuentos',
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
                          children: [],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 40, 0, 0),
                    child: Image.asset(
                      'assets/images/Promo_card-1.png',
                      width: double.infinity,
                      height: 112,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
                    child: Image.asset(
                      'assets/images/Promo_card-2.png',
                      width: double.infinity,
                      height: 112,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
                    child: Image.asset(
                      'assets/images/Promo_card-3.png',
                      width: double.infinity,
                      height: 112,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
                    child: Image.asset(
                      'assets/images/Promo_card-4.png',
                      width: double.infinity,
                      height: 112,
                      fit: BoxFit.fitWidth,
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
