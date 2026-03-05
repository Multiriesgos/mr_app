import 'package:go_router/go_router.dart';

import '../theme/fintech_theme.dart';
import '../theme/fintech_widgets.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class TransactionSuccessfulDailogWidget extends StatefulWidget {
  const TransactionSuccessfulDailogWidget({super.key});

  @override
  _TransactionSuccessfulDailogWidgetState createState() =>
      _TransactionSuccessfulDailogWidgetState();
}

class _TransactionSuccessfulDailogWidgetState
    extends State<TransactionSuccessfulDailogWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 289,
            height: 318,
            decoration: BoxDecoration(
              color: FinTechTheme.of(context).secondaryBackground,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 3,
                  color: Color(0x33000000),
                  offset: Offset(0, 1),
                )
              ],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                  child: const Icon(Icons.check_circle, size: 80, color: Colors.green),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  child: Text(
                    'Yahoo!',
                    textAlign: TextAlign.center,
                    style: FinTechTheme.of(context).bodyText1.override(
                          fontFamily: 'Inter',
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.4,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                  child: Text(
                    'Transaction successful',
                    textAlign: TextAlign.center,
                    style: FinTechTheme.of(context).bodyText1.override(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.normal,
                          lineHeight: 1.4,
                        ),
                  ),
                ),
                FFButtonWidget(
                  onPressed: () async {
                    await Future.delayed(const Duration(milliseconds: 2000));
                    Navigator.pop(context);
                    await SharePlus.instance.share(ShareParams(text: 'Transaction Receipt '));

                    context.pushNamed('Home');
                  },
                  text: 'E-receipt',
                  options: FFButtonOptions(
                    width: 166,
                    height: 36,
                    color: FinTechTheme.of(context).secondaryBackground,
                    textStyle: FinTechTheme.of(context).subtitle2.override(
                          fontFamily: 'Inter',
                          color: FinTechTheme.of(context).primaryText,
                          fontWeight: FontWeight.normal,
                        ),
                    elevation: 0,
                    borderSide: BorderSide(
                      color: FinTechTheme.of(context).primaryColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                FFButtonWidget(
                  onPressed: () async {
                    await Future.delayed(const Duration(milliseconds: 2000));
                    Navigator.pop(context);

                    context.pushNamed('Transactions');
                  },
                  text: 'Ok',
                  options: FFButtonOptions(
                    width: 166,
                    height: 36,
                    color: FinTechTheme.of(context).primaryColor,
                    textStyle: FinTechTheme.of(context).subtitle2.override(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
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
    );
  }
}
