import 'package:go_router/go_router.dart';

import '../theme/fintech_icon_button.dart';
import '../theme/fintech_theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:flutter/material.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  PageController? pageViewController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FinTechTheme.of(context).secondaryBackground,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good morning!',
                              style:
                                  FinTechTheme.of(context).bodyText1.override(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        letterSpacing: 1,
                                      ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                              child: Text(
                                'Feerd Sansco',
                                style:
                                    FinTechTheme.of(context).bodyText1.override(
                                          fontFamily: 'Inter',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 10, 0),
                                  child: InkWell(
                                    onTap: () async {
                                      context.pushNamed('Notification');
                                    },
                                    child: Icon(Icons.notifications, size: 31, color: FinTechTheme.of(context).primaryColor),
                                  ),
                                ),
                                Icon(Icons.person, size: 31, color: FinTechTheme.of(context).primaryColor),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 40, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance',
                              style:
                                  FinTechTheme.of(context).bodyText1.override(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                      ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 4, 0, 0),
                                  child: Text(
                                    '\$',
                                    style: FinTechTheme.of(context)
                                        .bodyText1
                                        .override(
                                          fontFamily: 'Inter',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      1, 4, 0, 0),
                                  child: Text(
                                    '1297',
                                    style: FinTechTheme.of(context)
                                        .bodyText1
                                        .override(
                                          fontFamily: 'Inter',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.28,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 50),
                                  child: PageView(
                                    controller: pageViewController ??=
                                        PageController(initialPage: 0),
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          context.pushNamed('MyCardsInfo');
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FinTechTheme.of(context)
                                                .secondaryBackground,
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: Image.asset(
                                                'assets/images/Card-bg-1.png',
                                              ).image,
                                            ),
                                          ),
                                          child: Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    20, 20, 20, 20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Image.asset(
                                                      'assets/images/vita.png',
                                                      width: 38,
                                                      height: 12,
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(0, 50, 0, 0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '0291 ',
                                                        style:
                                                            FinTechTheme.of(
                                                                    context)
                                                                .bodyText1
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: FinTechTheme.of(
                                                                          context)
                                                                      .primaryBtnText,
                                                                  fontSize: 18,
                                                                  letterSpacing:
                                                                      1.5,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(12, 0,
                                                                    5, 0),
                                                        child: Text(
                                                          '6281 ',
                                                          style: FinTechTheme
                                                                  .of(context)
                                                              .bodyText1
                                                              .override(
                                                                fontFamily:
                                                                    'Inter',
                                                                color: FinTechTheme.of(
                                                                        context)
                                                                    .primaryBtnText,
                                                                fontSize: 18,
                                                                letterSpacing:
                                                                    1.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(12, 0,
                                                                    5, 0),
                                                        child: Text(
                                                          ' 3820',
                                                          style: FinTechTheme
                                                                  .of(context)
                                                              .bodyText1
                                                              .override(
                                                                fontFamily:
                                                                    'Inter',
                                                                color: FinTechTheme.of(
                                                                        context)
                                                                    .primaryBtnText,
                                                                fontSize: 18,
                                                                letterSpacing:
                                                                    1.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(12, 0,
                                                                    0, 0),
                                                        child: Text(
                                                          '1821',
                                                          style: FinTechTheme
                                                                  .of(context)
                                                              .bodyText1
                                                              .override(
                                                                fontFamily:
                                                                    'Inter',
                                                                color: FinTechTheme.of(
                                                                        context)
                                                                    .primaryBtnText,
                                                                fontSize: 18,
                                                                letterSpacing:
                                                                    1.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(0, 10, 0, 0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '23/27',
                                                        style:
                                                            FinTechTheme.of(
                                                                    context)
                                                                .bodyText1
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: FinTechTheme.of(
                                                                          context)
                                                                      .primaryBtnText,
                                                                  fontSize: 18,
                                                                  letterSpacing:
                                                                      1.9,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(0, 15, 0, 0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Feerd Sansco',
                                                        style:
                                                            FinTechTheme.of(
                                                                    context)
                                                                .bodyText1
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: FinTechTheme.of(
                                                                          context)
                                                                      .primaryBtnText,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
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
                                      InkWell(
                                        onTap: () async {
                                          context.pushNamed('MyCardsInfoOne');
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FinTechTheme.of(context)
                                                .secondaryBackground,
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: Image.asset(
                                                'assets/images/Card-bg-2.png',
                                              ).image,
                                            ),
                                          ),
                                          child: Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    20, 20, 20, 20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Icon(Icons.credit_card, size: 32, color: FinTechTheme.of(context).primaryColor),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(0, 30, 0, 0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '0291 ',
                                                        style:
                                                            FinTechTheme.of(
                                                                    context)
                                                                .bodyText1
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: FinTechTheme.of(
                                                                          context)
                                                                      .primaryBtnText,
                                                                  fontSize: 18,
                                                                  letterSpacing:
                                                                      1.5,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(12, 0,
                                                                    5, 0),
                                                        child: Text(
                                                          '6281 ',
                                                          style: FinTechTheme
                                                                  .of(context)
                                                              .bodyText1
                                                              .override(
                                                                fontFamily:
                                                                    'Inter',
                                                                color: FinTechTheme.of(
                                                                        context)
                                                                    .primaryBtnText,
                                                                fontSize: 18,
                                                                letterSpacing:
                                                                    1.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(12, 0,
                                                                    5, 0),
                                                        child: Text(
                                                          ' 3820',
                                                          style: FinTechTheme
                                                                  .of(context)
                                                              .bodyText1
                                                              .override(
                                                                fontFamily:
                                                                    'Inter',
                                                                color: FinTechTheme.of(
                                                                        context)
                                                                    .primaryBtnText,
                                                                fontSize: 18,
                                                                letterSpacing:
                                                                    1.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(12, 0,
                                                                    0, 0),
                                                        child: Text(
                                                          '1821',
                                                          style: FinTechTheme
                                                                  .of(context)
                                                              .bodyText1
                                                              .override(
                                                                fontFamily:
                                                                    'Inter',
                                                                color: FinTechTheme.of(
                                                                        context)
                                                                    .primaryBtnText,
                                                                fontSize: 18,
                                                                letterSpacing:
                                                                    1.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(0, 10, 0, 0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '23/27',
                                                        style:
                                                            FinTechTheme.of(
                                                                    context)
                                                                .bodyText1
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: FinTechTheme.of(
                                                                          context)
                                                                      .primaryBtnText,
                                                                  fontSize: 18,
                                                                  letterSpacing:
                                                                      1.9,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(0, 15, 0, 0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Feerd Sansco',
                                                        style:
                                                            FinTechTheme.of(
                                                                    context)
                                                                .bodyText1
                                                                .override(
                                                                  fontFamily:
                                                                      'Inter',
                                                                  color: FinTechTheme.of(
                                                                          context)
                                                                      .primaryBtnText,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
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
                                Align(
                                  alignment: const AlignmentDirectional(0, 1),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 30),
                                    child: smooth_page_indicator
                                        .SmoothPageIndicator(
                                      controller: pageViewController ??=
                                          PageController(initialPage: 0),
                                      count: 2,
                                      axisDirection: Axis.horizontal,
                                      onDotClicked: (i) {
                                        pageViewController!.animateToPage(
                                          i,
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      },
                                      effect: smooth_page_indicator.SlideEffect(
                                        spacing: 6,
                                        radius: 16,
                                        dotWidth: 8,
                                        dotHeight: 8,
                                        dotColor: const Color(0xFF9E9E9E),
                                        activeDotColor: FinTechTheme.of(context)
                                            .secondaryColor,
                                        paintStyle: PaintingStyle.fill,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 82,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEBEB),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  context.pushNamed('Recipients');
                                },
                                child: Icon(Icons.send, size: 48, color: FinTechTheme.of(context).primaryColor),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                                child: Text(
                                  'Send',
                                  textAlign: TextAlign.center,
                                  style: FinTechTheme.of(context)
                                      .bodyText1
                                      .override(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  context.pushNamed('RecipientsRequest');
                                },
                                child: Icon(Icons.call_received, size: 48, color: FinTechTheme.of(context).primaryColor),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                                child: Text(
                                  'Request',
                                  textAlign: TextAlign.center,
                                  style: FinTechTheme.of(context)
                                      .bodyText1
                                      .override(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  context.pushNamed('Scanpay');
                                },
                                child: Icon(Icons.qr_code_2, size: 48, color: FinTechTheme.of(context).primaryColor),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                                child: Text(
                                  'Qr payments',
                                  textAlign: TextAlign.center,
                                  style: FinTechTheme.of(context)
                                      .bodyText1
                                      .override(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Services',
                              style: FinTechTheme.of(context).bodyText1,
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () async {
                                context.pushNamed('Allservices');
                              },
                              child: Text(
                                'See all',
                                style: FinTechTheme.of(context)
                                    .bodyText1
                                    .override(
                                      fontFamily: 'Inter',
                                      color:
                                          FinTechTheme.of(context).primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
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
                              fillColor: const Color(0xFFB8E4FF),
                              icon: Icon(
                                Icons.calendar_today_outlined,
                                color: FinTechTheme.of(context).secondaryColor,
                                size: 24,
                              ),
                              onPressed: () async {
                                context.pushNamed('Allservices');
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
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
                              fillColor: const Color(0xFFB8E4FF),
                              icon: Icon(
                                Icons.favorite_border_rounded,
                                color: FinTechTheme.of(context).secondaryColor,
                                size: 24,
                              ),
                              onPressed: () async {
                                context.pushNamed('Allservices');
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
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
                                context.pushNamed('Allservices');
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
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
                                context.pushNamed('Allservices');
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
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
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Promos',
                              style: FinTechTheme.of(context).bodyText1,
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () async {
                                context.pushNamed('Promosdiscount');
                              },
                              child: Text(
                                'See all',
                                style: FinTechTheme.of(context)
                                    .bodyText1
                                    .override(
                                      fontFamily: 'Inter',
                                      color:
                                          FinTechTheme.of(context).primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 25, 0, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          'assets/images/Promo_card.png',
                          width: 100,
                          height: 80,
                          fit: BoxFit.scaleDown,
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
    );
  }
}
