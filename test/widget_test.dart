import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pokedex/app.dart';

void main() {
  testWidgets('Pokedex app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const PokedexApp(),
        ),
      ),
    );

    expect(find.text('Pokedex'), findsOneWidget);
  });
}
