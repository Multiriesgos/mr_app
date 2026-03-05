import 'package:go_router/go_router.dart';

import '../theme/fintech_theme.dart';
import '../theme/fintech_widgets.dart';
import 'package:flutter/material.dart';

class TransactionsWidget extends StatefulWidget {
  const TransactionsWidget({super.key});

  @override
  _TransactionsWidgetState createState() => _TransactionsWidgetState();
}

class _TransactionsWidgetState extends State<TransactionsWidget> {
  PageController? pageViewController;
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
                              'Transactions',
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
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: pageViewController ??=
                          PageController(initialPage: 0),
                      scrollDirection: Axis.horizontal,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    FFButtonWidget(
                                      onPressed: () {},
                                      text: 'All',
                                      options: FFButtonOptions(
                                        width: 102,
                                        height: 28,
                                        color: FinTechTheme.of(context)
                                            .primaryColor,
                                        textStyle: FinTechTheme.of(context)
                                            .subtitle2
                                            .override(
                                              fontFamily: 'Inter',
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () async {
                                        await pageViewController?.nextPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.ease,
                                        );
                                      },
                                      text: 'Income',
                                      options: FFButtonOptions(
                                        width: 102,
                                        height: 28,
                                        color: FinTechTheme.of(context)
                                            .tertiaryColor,
                                        textStyle: FinTechTheme.of(context)
                                            .subtitle2
                                            .override(
                                              fontFamily: 'Inter',
                                              color: FinTechTheme.of(context)
                                                  .primaryText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                        elevation: 0,
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () async {
                                        await pageViewController?.animateToPage(
                                          2,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      },
                                      text: 'Expenses',
                                      options: FFButtonOptions(
                                        width: 102,
                                        height: 28,
                                        color: FinTechTheme.of(context)
                                            .tertiaryColor,
                                        textStyle: FinTechTheme.of(context)
                                            .subtitle2
                                            .override(
                                              fontFamily: 'Inter',
                                              color: FinTechTheme.of(context)
                                                  .primaryText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                        elevation: 0,
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Alliene Safer',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Expense',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFFDF1313),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Terrace',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Expense',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFFDF1313),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Shacica Alderson',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Income',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFF279A02),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Ihtasham A.',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Income',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFF279A02),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Sarim Kack',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Income',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFF279A02),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Sharik Narium',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Expense',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFFDF1313),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Ihtasham A.',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Expense',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFFDF1313),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Sana Javeed',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Expense',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFFDF1313),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    FFButtonWidget(
                                      onPressed: () async {
                                        await pageViewController?.animateToPage(
                                          0,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      },
                                      text: 'All',
                                      options: FFButtonOptions(
                                        width: 102,
                                        height: 28,
                                        color: FinTechTheme.of(context)
                                            .tertiaryColor,
                                        textStyle: FinTechTheme.of(context)
                                            .subtitle2
                                            .override(
                                              fontFamily: 'Inter',
                                              color: FinTechTheme.of(context)
                                                  .primaryText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                        elevation: 0,
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () {},
                                      text: 'Income',
                                      options: FFButtonOptions(
                                        width: 102,
                                        height: 28,
                                        color: FinTechTheme.of(context)
                                            .primaryColor,
                                        textStyle: FinTechTheme.of(context)
                                            .subtitle2
                                            .override(
                                              fontFamily: 'Inter',
                                              color: FinTechTheme.of(context)
                                                  .primaryBtnText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () async {
                                        await pageViewController?.animateToPage(
                                          2,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      },
                                      text: 'Expenses',
                                      options: FFButtonOptions(
                                        width: 102,
                                        height: 28,
                                        color: FinTechTheme.of(context)
                                            .tertiaryColor,
                                        textStyle: FinTechTheme.of(context)
                                            .subtitle2
                                            .override(
                                              fontFamily: 'Inter',
                                              color: FinTechTheme.of(context)
                                                  .primaryText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                        elevation: 0,
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Shacica Alderson',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Income',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFF279A02),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Ihtasham A.',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Income',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFF279A02),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Sarim Kack',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Income',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFF279A02),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    FFButtonWidget(
                                      onPressed: () async {
                                        await pageViewController?.animateToPage(
                                          0,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      },
                                      text: 'All',
                                      options: FFButtonOptions(
                                        width: 102,
                                        height: 28,
                                        color: FinTechTheme.of(context)
                                            .tertiaryColor,
                                        textStyle: FinTechTheme.of(context)
                                            .subtitle2
                                            .override(
                                              fontFamily: 'Inter',
                                              color: FinTechTheme.of(context)
                                                  .primaryText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                        elevation: 0,
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () async {
                                        await pageViewController?.previousPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.ease,
                                        );
                                      },
                                      text: 'Income',
                                      options: FFButtonOptions(
                                        width: 102,
                                        height: 28,
                                        color: FinTechTheme.of(context)
                                            .tertiaryColor,
                                        textStyle: FinTechTheme.of(context)
                                            .subtitle2
                                            .override(
                                              fontFamily: 'Inter',
                                              color: FinTechTheme.of(context)
                                                  .primaryText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                        elevation: 0,
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () {},
                                      text: 'Expenses',
                                      options: FFButtonOptions(
                                        width: 102,
                                        height: 28,
                                        color: FinTechTheme.of(context)
                                            .primaryColor,
                                        textStyle: FinTechTheme.of(context)
                                            .subtitle2
                                            .override(
                                              fontFamily: 'Inter',
                                              color: FinTechTheme.of(context)
                                                  .primaryBtnText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Alliene Safer',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Expense',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFFDF1313),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Terrace',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Expense',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFFDF1313),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Sharik Narium',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Expense',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFFDF1313),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Ihtasham A.',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Expense',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFFDF1313),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Container(
                                  width: 100,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: FinTechTheme.of(context)
                                        .secondaryBackground,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color(0x33000000),
                                        offset: Offset(0, 1),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 0, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                CircleAvatar(
                                                  radius: 25.5,
                                                  backgroundColor: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.2),
                                                  child: Icon(Icons.person, size: 30, color: FinTechTheme.of(context).primaryColor),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(5, 0, 0, 0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0, 0, 0, 4),
                                                        child: Text(
                                                          'Sana Javeed',
                                                          style:
                                                              FinTechTheme.of(
                                                                      context)
                                                                  .bodyText1,
                                                        ),
                                                      ),
                                                      Text(
                                                        '14th july, 2022 at 02:32 AM',
                                                        style: FinTechTheme.of(
                                                                context)
                                                            .bodyText1
                                                            .override(
                                                              fontFamily:
                                                                  'Inter',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  15, 0, 0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Expense',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: const Color(0xFFDF1313),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                              ),
                                              Text(
                                                '\$61',
                                                style: FinTechTheme.of(context)
                                                    .bodyText1
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      color: FinTechTheme.of(
                                                              context)
                                                          .primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                            ],
                          ),
                        ),
                      ],
                    ),
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
