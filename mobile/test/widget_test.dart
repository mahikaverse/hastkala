import 'package:flutter_test/flutter_test.dart';

import 'package:hastkala/app/app.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const HastKalaApp());
    await tester.pumpAndSettle();

    expect(find.text('HastKala'), findsWidgets);
  });
}
