import 'package:flutter_test/flutter_test.dart';
import 'package:minerva_claim_portal/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ClaimPortalApp());

    // Verify that the Login Screen is shown by checking for 'RP MITRA'
    expect(find.text('RP MITRA'), findsOneWidget);
    expect(find.text('Email *'), findsOneWidget);
    expect(find.text('Proceed'), findsOneWidget);
    expect(find.text('Login'), findsNothing);

    // Click proceed to see form selection and login button
    await tester.tap(find.text('Proceed'));
    await tester.pump();

    expect(find.text('Login'), findsOneWidget);
  });
}
