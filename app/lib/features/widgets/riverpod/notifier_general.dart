import 'package:app/core/services/key_value_storage_service_impl.dart';
import 'package:app/features/widgets/riverpod/state_general.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeneralNotifier extends StateNotifier<GeneralState> {
  final KeyValueStorageServiceImpl _keyValue;

  GeneralNotifier({required KeyValueStorageServiceImpl keyValue}) : _keyValue = keyValue, super(GeneralState()) {
    _init();
  }
  void _init() async {
    final openDrawer = await _keyValue.getValue<bool>("openDrawer");
    final languageCode = await _keyValue.getValue<String>("languageCode") ?? 'es';
    final countryCode = await _keyValue.getValue<String>("countryCode") ?? 'ES';
    final themeName = await _keyValue.getValue<String>('theme_mode');

    state = state.copyWith(open: openDrawer, langDefault: Locale(languageCode, countryCode), themeMode: _getThemeModeFromString(themeName ?? ''));
  }

  toggleLan(String languageCode, String countryCode) async {
    state = state.copyWith(langDefault: Locale(languageCode, countryCode));

    await _keyValue.setKeyValue<String>("languageCode", languageCode);
    await _keyValue.setKeyValue<String>("countryCode", countryCode);
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    await _keyValue.setKeyValue('theme_mode', mode.name);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _saveTheme(mode);
  }

  Future<void> toggleTheme() async {
    if (state.themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  ThemeMode _getThemeModeFromString(String themeName) {
    switch (themeName) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> toggleDrawer() async {
    if (state.open) {
      state = state.copyWith(open: !state.open);
    } else {
      state = state.copyWith(open: !state.open);
    }
    await _keyValue.setKeyValue<bool>("openDrawer", state.open);
  }

  Future<void> selectState({required int selectid}) async {
    state = state.copyWith(selectid: selectid);
  }
}
