import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:german_loop/main.dart';
import 'package:german_loop/data/models/phrase_model.dart';
import 'package:german_loop/data/models/word_gloss.dart';

void main() {
  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WordGlossAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PhraseModelAdapter());
    }

    await Hive.openBox<PhraseModel>('phrases');
    await Hive.openBox('settings');
  });

  tearDown(() async {
    await Hive.close();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GermanLoopApp(),
      ),
    );
    expect(find.byType(GermanLoopApp), findsOneWidget);
  });
}
