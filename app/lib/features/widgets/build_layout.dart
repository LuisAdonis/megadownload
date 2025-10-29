import 'package:app/features/widgets/elements/custom_app_bar.dart';
import 'package:app/features/widgets/elements/custom_side_bar.dart';
import 'package:app/features/widgets/riverpod/provider_general.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuildLayout extends ConsumerWidget {
  const BuildLayout({
    super.key,
    required this.showSidebar,
    required this.columns,
    required this.padding,
    required this.showButtonText,
    required this.showVelocity,
    required this.maxLines,
    required this.child,
  });
  final bool showSidebar;
  final int columns;
  final double padding;
  final bool showButtonText;
  final bool showVelocity;
  final int maxLines;
  final Widget child;
  @override
  Widget build(BuildContext context, ref) {
    final general = ref.watch(generalProvider);
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              if (general.open)
                Container(
                  width: 230,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: CustomSideBar(),
                ),
              Expanded(
                child: Column(
                  children: [
                    CustomAppBar(
                      showSidebar: showSidebar,
                      showButtonText: showButtonText,
                      padding: padding,
                    ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
