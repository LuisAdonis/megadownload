import 'package:flutter/material.dart';

class GeneralState {
  final ThemeMode themeMode;
  final Locale langDefault;
  final bool open;
  final int? selectid;

  GeneralState({
    this.themeMode = ThemeMode.system,
    this.langDefault = const Locale('es'),
    this.open = true,
    this.selectid = 0,
  });

  GeneralState copyWith({
    ThemeMode? themeMode,
    Locale? langDefault,
    bool? open,
    int? selectid,
  }) {
    return GeneralState(
      themeMode: themeMode ?? this.themeMode,
      langDefault: langDefault ?? this.langDefault,
      open: open ?? this.open,
      selectid: selectid ?? this.selectid,
    );
  }
}
