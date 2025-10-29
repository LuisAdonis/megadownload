import 'package:app/core/router/app_router.dart';
import 'package:app/features/widgets/riverpod/provider_general.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appouter = ref.watch(goRouterProvider);
    final general = ref.watch(generalProvider);
    return ShadApp.router(
      title: 'MegaDownload App',
      routerConfig: appouter,
      themeMode: general.themeMode,
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: ShadSlateColorScheme.dark(),
      ),

      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: ShadNeutralColorScheme.light(),
        breakpoints: ShadBreakpoints(
          tn: 0, // tiny
          sm: 640, // small
          md: 768, // medium
          lg: 1024, // large
          xl: 1280, // extra large
          xxl: 1536, // extra extra large
        ),
      ),
    );
  }
}
