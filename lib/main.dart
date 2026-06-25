import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'data/models/phrase_model.dart';
import 'data/models/word_gloss.dart';
import 'services/audio_service.dart';
import 'screens/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hive init
  await Hive.initFlutter();
  Hive.registerAdapter(WordGlossAdapter());
  Hive.registerAdapter(PhraseModelAdapter());

  await Hive.openBox<PhraseModel>('phrases');
  await Hive.openBox('settings');
  // Feature 2: word-level TTS cache (word → file path)
  await Hive.openBox<String>('word_audio');
  // Feature 3: foundations lesson progress (lesson key → completed bool)
  await Hive.openBox<bool>('foundations_progress');

  // Clean old audio files (non-blocking fire-and-forget)
  AudioService.cleanOldAudioFiles();

  runApp(
    const ProviderScope(
      child: GermanLoopApp(),
    ),
  );
}

class GermanLoopApp extends StatelessWidget {
  const GermanLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GermanLoop',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}
