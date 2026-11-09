import 'package:flutter_test/flutter_test.dart';
import 'package:skycast/main.dart';

void main() {
  testWidgets('SkyCast app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SkyCastApp());

    expect(find.text('SkyCast'), findsOneWidget);
    expect(find.text('Weather Forecast'), findsOneWidget);
    expect(find.text('Peshawar, Pakistan'), findsOneWidget);
  });
}
