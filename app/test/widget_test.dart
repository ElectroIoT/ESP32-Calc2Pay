// Smoke test: the app boots to the scan screen without a connected BLE
// device (no mock backend yet — this only proves the widget tree builds).

import 'package:flutter_test/flutter_test.dart';

import 'package:calc2pay_companion/main.dart';

void main() {
  testWidgets('App boots to the scan screen', (WidgetTester tester) async {
    await tester.pumpWidget(const Calc2PayApp());

    expect(find.text('Find your Calc2Pay device'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
  });
}
