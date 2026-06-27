import 'package:flutter_test/flutter_test.dart';
import 'package:shabakti/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ShabaktiApp());
    await tester.pump();
  });
}
