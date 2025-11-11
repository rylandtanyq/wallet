// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled1/i18n/strings.g.dart';

import 'package:untitled1/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ProviderScope(child: TranslationProvider(child: MyApp(hasWallets: false))));

    // 等一帧，确保不会抛异常就算过
    await tester.pumpAndSettle();

    expect(find.byType(MyApp), findsOneWidget);
  });
}
