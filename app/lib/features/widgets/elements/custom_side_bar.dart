import 'package:app/features/widgets/riverpod/provider_general.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CustomSideBar extends StatelessWidget {
  const CustomSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.download,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Download Manager',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Navigation
        Consumer(
          builder: (context, ref, child) {
            final general = ref.watch(generalProvider);
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildNavItem(
                    id: 0,
                    icon: LucideIcons.download,
                    label: 'Descargas',
                    isActive: general.selectid == 0,
                    onTap: () {
                      ref.read(generalProvider.notifier).selectState(selectid: 0);
                      context.push("/dashboard");
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildNavItem(
                    id: 1,
                    icon: LucideIcons.history,
                    label: 'Historial',
                    isActive: general.selectid == 1,
                    onTap: () {
                      ref.read(generalProvider.notifier).selectState(selectid: 1);

                      context.push("/page1");
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildNavItem(
                    id: 2,
                    icon: LucideIcons.settings,
                    label: 'Configuración',
                    isActive: general.selectid == 2,
                    onTap: () {
                      ref.read(generalProvider.notifier).selectState(selectid: 2);
                      context.push("/page2");
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavItem({required int id, required IconData icon, required String label, required bool isActive, Function()? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE2E8F0) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? Colors.grey.shade900 : Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.grey.shade900 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
