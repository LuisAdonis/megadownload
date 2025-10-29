import 'package:app/features/descargas/presentation/providers/download_provider.dart';
import 'package:app/features/widgets/elements/form_url.dart';
import 'package:app/features/widgets/riverpod/provider_general.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CustomAppBar extends ConsumerWidget {
  const CustomAppBar({super.key, required this.padding, required this.showButtonText, required this.showSidebar});
  final double padding;
  final bool showSidebar;
  final bool showButtonText;
  @override
  Widget build(BuildContext context, ref) {
    final general = ref.watch(generalProvider);
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        // color: Colors.white.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Menu button para mobile/tablet
              if (!showSidebar)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ShadButton.ghost(
                    leading: const Icon(
                      LucideIcons.menu,
                      size: 20,
                    ),
                    onPressed: () {
                      ref.read(generalProvider.notifier).toggleDrawer();
                      // setState(() {
                      //   _isSidebarOpen = !_isSidebarOpen;
                      // });
                    },
                    size: ShadButtonSize.sm,
                  ),
                ),
              Text(
                'Descargas',
                style: TextStyle(
                  fontSize: showSidebar ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              ShadIconButton(
                onPressed: () {
                  ref.read(generalProvider.notifier).toggleTheme();
                },
                icon: Icon(general.themeMode == ThemeMode.dark ? LucideIcons.moon : LucideIcons.sun),
              ),
              SizedBox(width: showButtonText ? 16 : 8),
              ShadButton(
                leading: const Icon(
                  LucideIcons.refreshCw,
                  size: 16,
                ),
                child: showButtonText ? const Text('Actualizar') : null,
                onPressed: () {
                  ref.read(downloadsProvider.notifier).init();
                },
              ),
              SizedBox(width: showButtonText ? 16 : 8),
              ShadButton(
                leading: const Icon(
                  LucideIcons.plus,
                  size: 16,
                ),
                child: showButtonText ? const Text('Nueva descarga') : null,
                onPressed: () {
                  showShadDialog(
                    context: context,
                    builder: (context) {
                      return FormUrl();
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
