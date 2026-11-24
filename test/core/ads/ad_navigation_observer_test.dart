
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tombis_world/core/ads/ad_navigation_observer.dart';

void main() {
  group('AdNavigationObserver', () {
    const splash = '/splash';
    const home = '/';
    const gallery = '/gallery';
    const coloring = '/coloring';
    const completion = '/completion';
    const settings = '/settings';

    late GlobalKey<NavigatorState> navigatorKey;
    late AdNavigationObserver observer;

    late int navigationCount;
    late int naturalBreakCount;
    late bool isColoring;

    bool Function()? presentationGuard;
    late bool throwOnNaturalBreak;

    setUp(() {
      navigatorKey = GlobalKey<NavigatorState>();

      navigationCount = 0;
      naturalBreakCount = 0;
      isColoring = false;

      presentationGuard = null;
      throwOnNaturalBreak = false;

      observer = AdNavigationObserver(
        onNavigation: () => navigationCount++,
        onColoringChanged: (value) {
          isColoring = value;
        },
        onNaturalBreak: ({
          bool Function()? isStillAtNaturalBreak,
        }) async {
          naturalBreakCount++;
          presentationGuard = isStillAtNaturalBreak;

          if (throwOnNaturalBreak) {
            throw StateError('Natural break failed');
          }

          return true;
        },
        coloringRouteName: coloring,
        completionRouteName: completion,
        splashRouteName: splash,
        naturalBreakDestinations: const {
          home,
          gallery,
        },
      );
    });

    NavigatorState getNavigator() {
      return navigatorKey.currentState!;
    }

    Future<void> startApp(
        WidgetTester tester, {
          String initialRoute = home,
        }) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [observer],
          initialRoute: initialRoute,
          onGenerateInitialRoutes: (routeName) {
            return [
              MaterialPageRoute<void>(
                settings: RouteSettings(name: routeName),
                builder: (_) => const Scaffold(),
              ),
            ];
          },
          onGenerateRoute: (routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (_) => const Scaffold(),
            );
          },
        ),
      );

      await tester.pumpAndSettle();
    }

    Future<void> push(
        WidgetTester tester,
        String route,
        ) async {
      getNavigator().pushNamed<void>(route);

      await tester.pumpAndSettle();
    }

    Future<void> pop(WidgetTester tester) async {
      getNavigator().pop();

      await tester.pumpAndSettle();
    }

    testWidgets(
      'initial route and splash transition are not counted',
          (tester) async {
        await startApp(
          tester,
          initialRoute: splash,
        );

        expect(navigationCount, 0);
        expect(naturalBreakCount, 0);

        getNavigator().pushReplacementNamed<void, void>(
          home,
        );

        await tester.pumpAndSettle();

        expect(navigationCount, 0);
        expect(naturalBreakCount, 0);
        expect(isColoring, isFalse);
      },
    );

    testWidgets(
      'normal navigation is counted without triggering ads',
          (tester) async {
        await startApp(tester);

        await push(tester, settings);
        expect(navigationCount, 1);

        await pop(tester);
        expect(navigationCount, 2);

        await push(tester, gallery);
        expect(navigationCount, 3);

        expect(naturalBreakCount, 0);
        expect(isColoring, isFalse);
      },
    );

    testWidgets(
      'coloring and completion belong to the same flow',
          (tester) async {
        await startApp(
          tester,
          initialRoute: gallery,
        );

        await push(tester, coloring);

        expect(navigationCount, 1);
        expect(isColoring, isTrue);
        expect(naturalBreakCount, 0);

        await push(tester, completion);

        expect(navigationCount, 1);
        expect(isColoring, isTrue);
        expect(naturalBreakCount, 0);

        await pop(tester);

        expect(navigationCount, 1);
        expect(isColoring, isTrue);
        expect(naturalBreakCount, 0);
      },
    );

    for (final source in [coloring, completion]) {
      for (final destination in [home, gallery]) {
        testWidgets(
          '$source to $destination triggers one natural break',
              (tester) async {
            await startApp(
              tester,
              initialRoute: destination,
            );

            await push(tester, source);

            expect(isColoring, isTrue);
            expect(navigationCount, 1);
            expect(naturalBreakCount, 0);

            await pop(tester);

            expect(isColoring, isFalse);
            expect(navigationCount, 2);
            expect(naturalBreakCount, 1);

            expect(presentationGuard, isNotNull);
            expect(presentationGuard!(), isTrue);

            await tester.pumpAndSettle();

            expect(naturalBreakCount, 1);
          },
        );
      }
    }

    testWidgets(
      'leaving coloring for settings does not trigger an ad',
          (tester) async {
        await startApp(
          tester,
          initialRoute: coloring,
        );

        await push(tester, settings);

        expect(navigationCount, 1);
        expect(naturalBreakCount, 0);
        expect(isColoring, isFalse);
      },
    );

    testWidgets(
      'opening and closing dialogs does not count as navigation',
          (tester) async {
        await startApp(
          tester,
          initialRoute: coloring,
        );

        showDialog<void>(
          context: navigatorKey.currentContext!,
          builder: (_) => const AlertDialog(
            title: Text('Leave coloring?'),
          ),
        );

        await tester.pumpAndSettle();

        expect(navigationCount, 0);
        expect(naturalBreakCount, 0);
        expect(isColoring, isTrue);

        await pop(tester);

        expect(navigationCount, 0);
        expect(naturalBreakCount, 0);
        expect(isColoring, isTrue);
      },
    );

    testWidgets(
      'presentation guard rejects an outdated destination',
          (tester) async {
        await startApp(
          tester,
          initialRoute: gallery,
        );

        await push(tester, coloring);
        await pop(tester);

        final guard = presentationGuard!;

        expect(guard(), isTrue);

        await push(tester, coloring);

        expect(guard(), isFalse);
        expect(isColoring, isTrue);
        expect(naturalBreakCount, 1);
      },
    );

    testWidgets(
      'presentation guard blocks ads while a dialog is open',
          (tester) async {
        await startApp(
          tester,
          initialRoute: gallery,
        );

        await push(tester, coloring);
        await pop(tester);

        final guard = presentationGuard!;

        expect(guard(), isTrue);

        showDialog<void>(
          context: navigatorKey.currentContext!,
          builder: (_) => const AlertDialog(
            title: Text('Test dialog'),
          ),
        );

        await tester.pumpAndSettle();

        expect(guard(), isFalse);

        await pop(tester);

        expect(guard(), isTrue);
        expect(naturalBreakCount, 1);
        expect(navigationCount, 2);
      },
    );

    testWidgets(
      'natural break errors do not interrupt navigation',
          (tester) async {
        await startApp(
          tester,
          initialRoute: gallery,
        );

        throwOnNaturalBreak = true;

        await push(tester, coloring);
        await pop(tester);

        expect(naturalBreakCount, 1);
        expect(tester.takeException(), isNull);

        throwOnNaturalBreak = false;

        await push(tester, coloring);
        await pop(tester);

        expect(naturalBreakCount, 2);
        expect(tester.takeException(), isNull);
        expect(isColoring, isFalse);
      },
    );
  });
}
