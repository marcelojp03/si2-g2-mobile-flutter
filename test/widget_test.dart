import 'package:flutter_test/flutter_test.dart';
import 'package:si2_g2_mobile/main.dart';

void main() {
  testWidgets('App loads without error', (WidgetTester tester) async {
    await tester.pumpWidget(const SiaApp());
    expect(find.byType(SiaApp), findsOneWidget);
  });
}
