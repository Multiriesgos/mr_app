import 'package:go_router/go_router.dart';

import '../components/transaction_successful_dailog_widget.dart';
import '../theme/fintech_drop_down.dart';
import '../theme/fintech_theme.dart';
import '../theme/fintech_widgets.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';

class BillPaymentsWidget extends StatefulWidget {
  const BillPaymentsWidget({super.key});

  @override
  _BillPaymentsWidgetState createState() => _BillPaymentsWidgetState();
}

class _BillPaymentsWidgetState extends State<BillPaymentsWidget> {
  PageController? pageViewController;
  String? dropDownValue;
  TextEditingController? textController;
  TextEditingController? pinCodeController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    pinCodeController = TextEditingController();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FinTechTheme.of(context).primaryBackground,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageViewController ??= PageController(initialPage: 0),
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  child: SingleChildScrollView(
                    primary: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    context.pop();
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
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      5, 0, 0, 0),
                                  child: Text(
                                    'Bill Payments',
                                    textAlign: TextAlign.center,
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
                              children: [],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: 121,
                                          height: 121,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.1),
                                          ),
                                          child: Icon(Icons.receipt, size: 60, color: FinTechTheme.of(context).primaryColor),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  0, 20, 0, 0),
                                          child: Text(
                                            'Bill Payments',
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 70, 0, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                'Catagories',
                                style: FinTechTheme.of(context).bodyText1,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 70,
                          decoration: BoxDecoration(
                            color: FinTechTheme.of(context).secondaryBackground,
                            shape: BoxShape.rectangle,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    10, 0, 10, 0),
                                child: FinTechDropDown(
                                  options: const ['Option1', 'Option2', 'Option2'],
                                  onChanged: (val) =>
                                      setState(() => dropDownValue = val),
                                  width: 100,
                                  height: 50,
                                  textStyle: FinTechTheme.of(context)
                                      .bodyText1
                                      .override(
                                        fontFamily: 'Inter',
                                        color: Colors.black,
                                      ),
                                  hintText: 'Option2',
                                  fillColor: Colors.white,
                                  elevation: 2,
                                  borderColor: const Color(0xFFDDDDDD),
                                  borderWidth: 0,
                                  borderRadius: 8,
                                  margin: const EdgeInsetsDirectional.fromSTEB(
                                      12, 4, 12, 4),
                                  hidesUnderline: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                'Consumer ID',
                                style: FinTechTheme.of(context).bodyText1,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                          child: Container(
                            width: 100,
                            height: 50,
                            decoration: BoxDecoration(
                              color:
                                  FinTechTheme.of(context).secondaryBackground,
                              shape: BoxShape.rectangle,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: textController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    hintText: 'Enter',
                                    hintStyle:
                                        FinTechTheme.of(context).bodyText2,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0xFFC4C4C4),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0xFFC4C4C4),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0x00000000),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0x00000000),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                  ),
                                  style: FinTechTheme.of(context).bodyText1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 65, 0, 30),
                          child: FFButtonWidget(
                            onPressed: () async {
                              await Future.delayed(
                                  const Duration(milliseconds: 2000));
                              await pageViewController?.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            },
                            text: 'Continue',
                            options: FFButtonOptions(
                              width: 130,
                              height: 48,
                              color: FinTechTheme.of(context).primaryColor,
                              textStyle:
                                  FinTechTheme.of(context).subtitle2.override(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  child: SingleChildScrollView(
                    primary: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await pageViewController?.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.ease,
                                    );
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
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      15, 0, 0, 0),
                                  child: Text(
                                    'Confirmation',
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
                              children: [],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
                          child: Container(
                            width: double.infinity,
                            height: 250,
                            decoration: BoxDecoration(
                              color: FinTechTheme.of(context).primaryBtnText,
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
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: 121,
                                            height: 121,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: FinTechTheme.of(context).primaryColor.withValues(alpha: 0.1),
                                            ),
                                            child: Icon(Icons.receipt, size: 60, color: FinTechTheme.of(context).primaryColor),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    0, 20, 0, 0),
                                            child: Text(
                                              'Bill Payments',
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
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                          child: Container(
                            width: 100,
                            height: 130,
                            decoration: BoxDecoration(
                              color:
                                  FinTechTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(8),
                              shape: BoxShape.rectangle,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      15, 15, 15, 15),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Paying to',
                                        style: FinTechTheme.of(context)
                                            .bodyText1
                                            .override(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w300,
                                            ),
                                      ),
                                      Text(
                                        'Electricity Bill',
                                        style:
                                            FinTechTheme.of(context).bodyText1,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      15, 5, 15, 15),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'ID',
                                        style: FinTechTheme.of(context)
                                            .bodyText1
                                            .override(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w300,
                                            ),
                                      ),
                                      Text(
                                        '1266303823',
                                        style:
                                            FinTechTheme.of(context).bodyText1,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      15, 5, 15, 15),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Status',
                                        style: FinTechTheme.of(context)
                                            .bodyText1
                                            .override(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w300,
                                            ),
                                      ),
                                      Text(
                                        'Unpaid',
                                        style:
                                            FinTechTheme.of(context).bodyText1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              await Future.delayed(
                                  const Duration(milliseconds: 2000));
                              await pageViewController?.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            },
                            text: 'Continue',
                            options: FFButtonOptions(
                              width: 130,
                              height: 48,
                              color: FinTechTheme.of(context).primaryColor,
                              textStyle:
                                  FinTechTheme.of(context).subtitle2.override(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
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
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await pageViewController?.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.ease,
                                    );
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
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      15, 0, 0, 0),
                                  child: Text(
                                    'Confirmation',
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
                              children: [],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: SingleChildScrollView(
                          primary: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 120, 0, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          Icons.pin,
                                          size: 79,
                                          color: FinTechTheme.of(context).primaryColor,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  0, 20, 0, 0),
                                          child: Text(
                                            'Enter your PIN',
                                            style: FinTechTheme.of(context)
                                                .bodyText1
                                                .override(
                                                  fontFamily: 'Inter',
                                                  fontSize: 24,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  0, 10, 0, 0),
                                          child: Text(
                                            'Please enter your PIN to confirm \nyour paymet.',
                                            textAlign: TextAlign.center,
                                            style: FinTechTheme.of(context)
                                                .bodyText1
                                                .override(
                                                  fontFamily: 'Inter',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                                child: PinCodeTextField(
                                  appContext: context,
                                  length: 4,
                                  textStyle: FinTechTheme.of(context)
                                      .subtitle2
                                      .override(
                                        fontFamily: 'Inter',
                                        color: FinTechTheme.of(context)
                                            .primaryText,
                                      ),
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  enableActiveFill: true,
                                  autoFocus: true,
                                  showCursor: true,
                                  cursorColor:
                                      FinTechTheme.of(context).primaryColor,
                                  obscureText: false,
                                  hintCharacter: '●',
                                  pinTheme: PinTheme(
                                    fieldHeight: 60,
                                    fieldWidth: 60,
                                    borderWidth: 2,
                                    borderRadius: BorderRadius.circular(12),
                                    shape: PinCodeFieldShape.box,
                                    activeColor:
                                        FinTechTheme.of(context).primaryColor,
                                    inactiveColor: FinTechTheme.of(context)
                                        .primaryBackground,
                                    selectedColor:
                                        FinTechTheme.of(context).primaryBtnText,
                                    activeFillColor:
                                        FinTechTheme.of(context).primaryColor,
                                    inactiveFillColor: FinTechTheme.of(context)
                                        .primaryBackground,
                                    selectedFillColor:
                                        FinTechTheme.of(context).primaryBtnText,
                                  ),
                                  controller: pinCodeController,
                                  onChanged: (_) => {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FFButtonWidget(
                              onPressed: () async {
                                await Future.delayed(
                                    const Duration(milliseconds: 2000));
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding:
                                          MediaQuery.of(context).viewInsets,
                                      child: const SizedBox(
                                        height: double.infinity,
                                        child:
                                            TransactionSuccessfulDailogWidget(),
                                      ),
                                    );
                                  },
                                ).then((value) => setState(() {}));
                              },
                              text: 'Pay now',
                              options: FFButtonOptions(
                                width: 130,
                                height: 45,
                                color: FinTechTheme.of(context).primaryColor,
                                textStyle:
                                    FinTechTheme.of(context).subtitle2.override(
                                          fontFamily: 'Inter',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
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
    );
  }
}
