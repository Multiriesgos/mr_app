import 'package:go_router/go_router.dart';

import '../theme/fintech_icon_button.dart';
import '../theme/fintech_theme.dart';
import 'package:flutter/material.dart';

class AllservicesWidget extends StatefulWidget {
  const AllservicesWidget({super.key});

  @override
  _AllservicesWidgetState createState() => _AllservicesWidgetState();
}

class _AllservicesWidgetState extends State<AllservicesWidget> {
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
                              context.pushNamed('Home');
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
                            padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                            child: Text(
                              'All services',
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
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Most Used',
                        style: FinTechTheme.of(context).bodyText1.override(
                              fontFamily: 'Inter',
                              fontSize: 16,
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FinTechIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 30,
                            borderWidth: 1,
                            buttonSize: 60,
                            fillColor: FinTechTheme.of(context).tertiaryColor,
                            icon: Icon(
                              Icons.calendar_today_outlined,
                              color: FinTechTheme.of(context).secondaryColor,
                              size: 24,
                            ),
                            onPressed: () async {
                              context.pushNamed('Recipients');
                            },
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                            child: Text(
                              'Schedule',
                              textAlign: TextAlign.center,
                              style:
                                  FinTechTheme.of(context).bodyText1.override(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                      ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FinTechIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 30,
                            borderWidth: 1,
                            buttonSize: 60,
                            fillColor: FinTechTheme.of(context).tertiaryColor,
                            icon: Icon(
                              Icons.favorite_border_rounded,
                              color: FinTechTheme.of(context).secondaryColor,
                              size: 24,
                            ),
                            onPressed: () async {
                              context.pushNamed('Recipients');
                            },
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                            child: Text(
                              'Favourites',
                              textAlign: TextAlign.center,
                              style:
                                  FinTechTheme.of(context).bodyText1.override(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                      ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FinTechIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 30,
                            borderWidth: 1,
                            buttonSize: 60,
                            fillColor: FinTechTheme.of(context).tertiaryColor,
                            icon: Icon(
                              Icons.import_export_rounded,
                              color: FinTechTheme.of(context).secondaryColor,
                              size: 24,
                            ),
                            onPressed: () async {
                              context.pushNamed('Recipients');
                            },
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                            child: Text(
                              'Exchange',
                              textAlign: TextAlign.center,
                              style:
                                  FinTechTheme.of(context).bodyText1.override(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                      ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FinTechIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 30,
                            borderWidth: 1,
                            buttonSize: 60,
                            fillColor: FinTechTheme.of(context).tertiaryColor,
                            icon: Icon(
                              Icons.attach_money,
                              color: FinTechTheme.of(context).secondaryColor,
                              size: 24,
                            ),
                            onPressed: () async {
                              context.pushNamed('Recipients');
                            },
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                            child: Text(
                              'International',
                              textAlign: TextAlign.center,
                              style:
                                  FinTechTheme.of(context).bodyText1.override(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Important',
                        style: FinTechTheme.of(context).bodyText1.override(
                              fontFamily: 'Inter',
                              fontSize: 16,
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FinTechIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 30,
                            borderWidth: 1,
                            buttonSize: 60,
                            fillColor: FinTechTheme.of(context).alternate,
                            icon: Icon(
                              Icons.history_outlined,
                              color: FinTechTheme.of(context).primaryColor,
                              size: 24,
                            ),
                            onPressed: () async {
                              context.pushNamed('BillPayments');
                            },
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                            child: Text(
                              'Pay later',
                              textAlign: TextAlign.center,
                              style:
                                  FinTechTheme.of(context).bodyText1.override(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                      ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FinTechIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 30,
                            borderWidth: 1,
                            buttonSize: 60,
                            fillColor: FinTechTheme.of(context).alternate,
                            icon: Icon(
                              Icons.privacy_tip_outlined,
                              color: FinTechTheme.of(context).primaryColor,
                              size: 24,
                            ),
                            onPressed: () async {
                              context.pushNamed('BillPayments');
                            },
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                            child: Text(
                              'Insurance',
                              textAlign: TextAlign.center,
                              style:
                                  FinTechTheme.of(context).bodyText1.override(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                      ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FinTechIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 30,
                            borderWidth: 1,
                            buttonSize: 60,
                            fillColor: FinTechTheme.of(context).alternate,
                            icon: Icon(
                              Icons.star_outline_rounded,
                              color: FinTechTheme.of(context).primaryColor,
                              size: 24,
                            ),
                            onPressed: () async {
                              context.pushNamed('BillPayments');
                            },
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                            child: Text(
                              'Favourites',
                              textAlign: TextAlign.center,
                              style:
                                  FinTechTheme.of(context).bodyText1.override(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                      ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FinTechIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 30,
                            borderWidth: 1,
                            buttonSize: 60,
                            fillColor: FinTechTheme.of(context).alternate,
                            icon: Icon(
                              Icons.school_outlined,
                              color: FinTechTheme.of(context).primaryColor,
                              size: 24,
                            ),
                            onPressed: () async {
                              context.pushNamed('BillPayments');
                            },
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                            child: Text(
                              'Education',
                              textAlign: TextAlign.center,
                              style:
                                  FinTechTheme.of(context).bodyText1.override(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Least used',
                        style: FinTechTheme.of(context).bodyText1.override(
                              fontFamily: 'Inter',
                              fontSize: 16,
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FinTechIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 30,
                            borderWidth: 1,
                            buttonSize: 60,
                            fillColor: const Color(0xFFFCDDEC),
                            icon: const Icon(
                              Icons.person_outline_outlined,
                              color: Color(0xFFF178B6),
                              size: 24,
                            ),
                            onPressed: () async {
                              context.pushNamed('Recipients');
                            },
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                            child: Text(
                              'Contact',
                              textAlign: TextAlign.center,
                              style:
                                  FinTechTheme.of(context).bodyText1.override(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                      ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FinTechIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 30,
                            borderWidth: 1,
                            buttonSize: 60,
                            fillColor: const Color(0xFFFCDDEC),
                            icon: const Icon(
                              Icons.receipt_long_rounded,
                              color: Color(0xFFF178B6),
                              size: 24,
                            ),
                            onPressed: () async {
                              context.pushNamed('BillPayments');
                            },
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                            child: Text(
                              'Bill payment',
                              textAlign: TextAlign.center,
                              style:
                                  FinTechTheme.of(context).bodyText1.override(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                      ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FinTechIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 30,
                            borderWidth: 1,
                            buttonSize: 60,
                            fillColor: const Color(0xFFFCDDEC),
                            icon: const Icon(
                              Icons.article_outlined,
                              color: Color(0xFFF178B6),
                              size: 24,
                            ),
                            onPressed: () async {
                              context.pushNamed('Promosdiscount');
                            },
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                            child: Text(
                              'Promos',
                              textAlign: TextAlign.center,
                              style:
                                  FinTechTheme.of(context).bodyText1.override(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                      ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FinTechIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 30,
                            borderWidth: 1,
                            buttonSize: 60,
                            fillColor: const Color(0xFFFCDDEC),
                            icon: const Icon(
                              Icons.credit_card,
                              color: Color(0xFFF178B6),
                              size: 24,
                            ),
                            onPressed: () async {
                              context.pushNamed('MyCards');
                            },
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                            child: Text(
                              'Switch card',
                              textAlign: TextAlign.center,
                              style:
                                  FinTechTheme.of(context).bodyText1.override(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
