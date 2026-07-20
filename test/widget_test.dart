import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyloop_mobile/main.dart';

void main() {
  testWidgets('StudyLoop starts with privacy-first onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const StudyLoopApp());
    await tester.pumpAndSettle();

    expect(find.text('Learn at the right moment.'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -650));
    await tester.pumpAndSettle();
    expect(find.text('Create my first loop'), findsOneWidget);
  });
}
