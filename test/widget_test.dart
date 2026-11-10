
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tombis_world/app/app.dart';

void main() {
  testWidgets('App starts successfully', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TombisWorldApp(),
      ),
    );

    expect(find.text("Tombi's World"), findsOneWidget);
  });
}
