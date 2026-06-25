import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'dart:io' show Platform;

const _tokenKey = 'hf_api_token';
const _settingsBox = 'settings';

class AppSettings {
  final String token;
  final bool formalDefault;
  final bool lightweightMode;
  final double defaultPlaybackSpeed;
  final bool requirePracticeBeforeSave;

  const AppSettings({
    this.token = '',
    this.formalDefault = false,
    this.lightweightMode = false,
    this.defaultPlaybackSpeed = 1.0,
    this.requirePracticeBeforeSave = false,
  });

  AppSettings copyWith({
    String? token,
    bool? formalDefault,
    bool? lightweightMode,
    double? defaultPlaybackSpeed,
    bool? requirePracticeBeforeSave,
  }) =>
      AppSettings(
        token: token ?? this.token,
        formalDefault: formalDefault ?? this.formalDefault,
        lightweightMode: lightweightMode ?? this.lightweightMode,
        defaultPlaybackSpeed: defaultPlaybackSpeed ?? this.defaultPlaybackSpeed,
        requirePracticeBeforeSave: requirePracticeBeforeSave ?? this.requirePracticeBeforeSave,
      );
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _storage = FlutterSecureStorage();

  @override
  Future<AppSettings> build() async {
    // Load from secure storage first; fall back to HF_API_KEY env var
    String token = await _storage.read(key: _tokenKey) ?? '';
    if (token.isEmpty) {
      final envToken = Platform.environment['HF_API_KEY'] ?? '';
      if (envToken.isNotEmpty) {
        // Persist it so subsequent launches don't need the env var
        await _storage.write(key: _tokenKey, value: envToken);
        token = envToken;
      }
    }
    final box = Hive.box(_settingsBox);
    return AppSettings(
      token: token,
      formalDefault: (box.get('formalDefault') ?? false) as bool,
      lightweightMode: (box.get('lightweightMode') ?? false) as bool,
      defaultPlaybackSpeed: ((box.get('defaultPlaybackSpeed') ?? 1.0) as num).toDouble(),
      requirePracticeBeforeSave:
          (box.get('requirePracticeBeforeSave') ?? false) as bool,
    );
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(token: token));
  }

  Future<void> setFormalDefault(bool value) async {
    Hive.box(_settingsBox).put('formalDefault', value);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(formalDefault: value));
  }

  Future<void> setLightweightMode(bool value) async {
    Hive.box(_settingsBox).put('lightweightMode', value);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(lightweightMode: value));
  }

  Future<void> setDefaultPlaybackSpeed(double value) async {
    Hive.box(_settingsBox).put('defaultPlaybackSpeed', value);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(defaultPlaybackSpeed: value));
  }

  Future<void> setRequirePractice(bool value) async {
    Hive.box(_settingsBox).put('requirePracticeBeforeSave', value);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(requirePracticeBeforeSave: value));
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

/// Convenience provider for the HF token only.
final hfTokenProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.token ?? '';
});
