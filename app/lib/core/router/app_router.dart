import 'package:app/features/descargas/presentation/page/descarga_historial_page.dart';
import 'package:app/features/descargas/presentation/page/descargas_page.dart';
import 'package:app/features/page_test.dart';
import 'package:app/features/splash/splas_page.dart';
import 'package:app/features/widgets/custom_navegation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => SplasPage(),
      ),

      ShellRoute(
        builder: (context, state, child) => CustomNavegation(childp: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => DescargasPage(),
          ),
          GoRoute(
            path: '/historial',
            builder: (context, state) => DescargaHistorialPage(),
          ),
          GoRoute(
            path: '/page2',
            builder: (context, state) => PageTest(),
          ),
        ],
      ),
    ],
  );
});
