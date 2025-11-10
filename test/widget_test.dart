// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:recipe_parser/src/app.dart';

void main() {
  testWidgets('Home screen renders quick actions', (tester) async {
    await tester.pumpWidget(const RecipeParserApp());
    await tester.pumpAndSettle();

    expect(find.text('Recipe Parser'), findsWidgets);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Add a recipe from URL'), findsOneWidget);
  });
}
