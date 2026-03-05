import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:go_router/go_router.dart';
import 'package:mr_app/views/home_view.dart';
import 'package:mr_app/views/product.dart';
import 'package:page_transition/page_transition.dart';

import '../../index.dart';
import '../../main.dart';
import 'serialization_util.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

class AppStateNotifier extends ChangeNotifier {
  bool showSplashImage = false;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: kDebugMode,
      refreshListenable: appStateNotifier,
      errorBuilder: (context, _) => appStateNotifier.showSplashImage
          ? Builder(
              builder: (context) => Container(
                color: Colors.transparent,
                child: Image.asset(
                  'assets/images/splash-screen.png',
                  fit: BoxFit.fill,
                ),
              ),
            )
          : const Splash2(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => appStateNotifier.showSplashImage
              ? Builder(
                  builder: (context) => Container(
                    color: Colors.transparent,
                    child: Image.asset(
                      'assets/images/splash-screen.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              : const Splash2(),
          routes: [
            FFRoute(
              name: 'SecondScreen',
              path: 'secondscreen',
              builder: (context, params) => const SecondScreen(title: '', item: null),
            ),
            FFRoute(
              name: 'HomeView',
              path: 'homeview',
              builder: (context, state) => const HomeView(),
            ),
            FFRoute(
              name: 'Product',
              path: 'product',
              builder: (context, params) => const Product(),
            ),
            FFRoute(
              name: 'Home',
              path: 'home',
              builder: (context, params) => params.isEmpty
                  ? const NavBarPage(initialPage: 'Home')
                  : const HomeWidget(),
            ),
            FFRoute(
              name: 'Allservices',
              path: 'allservices',
              builder: (context, params) => const AllservicesWidget(),
            ),
            FFRoute(
              name: 'Promosdiscount',
              path: 'promosdiscount',
              builder: (context, params) => const PromosdiscountWidget(),
            ),
            FFRoute(
              name: 'Notification',
              path: 'notification',
              builder: (context, params) => const NotificationWidget(),
            ),
            FFRoute(
              name: 'Recipients',
              path: 'recipients',
              builder: (context, params) => const RecipientsWidget(),
            ),
            FFRoute(
              name: 'RecipientsRequest',
              path: 'recipientsRequest',
              builder: (context, params) => const RecipientsRequestWidget(),
            ),
            FFRoute(
              name: 'Scanpay',
              path: 'scanpay',
              builder: (context, params) => const ScanpayWidget(),
            ),
            FFRoute(
              name: 'BillPayments',
              path: 'billPayments',
              builder: (context, params) => const BillPaymentsWidget(),
            ),
            FFRoute(
              name: 'MyCards',
              path: 'myCards',
              builder: (context, params) => params.isEmpty
                  ? const NavBarPage(initialPage: 'MyCards')
                  : const MyCardsWidget(),
            ),
            FFRoute(
              name: 'MyCardsInfoOne',
              path: 'myCardsInfoOne',
              builder: (context, params) => const MyCardsInfoOneWidget(),
            ),
            FFRoute(
              name: 'Transactions',
              path: 'transactions',
              builder: (context, params) => params.isEmpty
                  ? const NavBarPage(initialPage: 'Transactions')
                  : const TransactionsWidget(),
            ),
            FFRoute(
              name: 'MyCardsInfo',
              path: 'myCardsInfo',
              builder: (context, params) => const MyCardsInfoWidget(),
            ),
            FFRoute(
              name: 'Profile',
              path: 'profile',
              builder: (context, params) => params.isEmpty
                  ? const NavBarPage(initialPage: 'Profile')
                  : const ProfileWidget(),
            ),
            FFRoute(
              name: 'EditProfile',
              path: 'editProfile',
              builder: (context, params) => const EditProfileWidget(),
            )
          ].map((r) => r.toRoute(appStateNotifier)).toList(),
        ).toRoute(appStateNotifier),
      ],
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.extraMap.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, [
    bool isList = false,
  ]) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder: PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).transitionsBuilder,
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => const TransitionInfo(
        hasTransition: true,
        transitionType: PageTransitionType.fade,
        duration: Duration(milliseconds: 300),
      );
}
