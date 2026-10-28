// Basic Flutter widget test for Daksh App

import 'package:flutter_test/flutter_test.dart';
import 'package:daksh/app.dart';

void main() {
  testWidgets('DakshApp renders dashboard smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DakshApp());
    await tester.pump(const Duration(milliseconds: 3000));

    expect(find.byType(DakshApp), findsOneWidget);
  });
}
