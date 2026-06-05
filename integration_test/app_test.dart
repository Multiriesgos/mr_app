import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mr_app/main.dart' show MyApp;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget buildApp() => const ProviderScope(child: MyApp());

  void setPortraitHD(WidgetTester tester) {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('Smoke tests — flujo principal', () {
    testWidgets(
      'app arranca y muestra la pantalla splash',
      (tester) async {
        setPortraitHD(tester);
        await tester.pumpWidget(buildApp());
        await tester.pump();

        expect(find.text('MULTIRIESGOS'), findsOneWidget);
      },
    );

    testWidgets(
      'la splash cede paso a la pantalla de login',
      (tester) async {
        setPortraitHD(tester);
        await tester.pumpWidget(buildApp());
        await tester.pump();

        expect(find.text('MULTIRIESGOS'), findsOneWidget);

        // Avanzar 5 s para disparar Timer(4 s) + transición GoRouter (1 s)
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        expect(find.text('MULTIRIESGOS'), findsNothing);
      },
    );
  });
}
