import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:app/features/widgets/build_layout.dart';

class CustomNavegation extends StatelessWidget {
  const CustomNavegation({super.key, required this.childp});
  final Widget childp;

  @override
  Widget build(BuildContext context) {
    return ShadResponsiveBuilder(
      builder: (context, breakpoint) {
        return switch (breakpoint) {
          ShadBreakpointTN() => BuildLayout(
            showSidebar: false,
            columns: 2,
            padding: 12,
            showButtonText: false,
            showVelocity: false,
            maxLines: 2,
            child: childp,
          ),
          ShadBreakpointSM() => BuildLayout(
            showSidebar: false,
            columns: 2,
            padding: 16,
            showButtonText: false,
            showVelocity: false,
            maxLines: 2,
            child: childp,
          ),
          ShadBreakpointMD() => BuildLayout(
            showSidebar: true,
            columns: 4,
            padding: 24,
            showButtonText: true,
            showVelocity: true,
            maxLines: 1,
            child: childp,
          ),
          ShadBreakpointLG() => BuildLayout(
            showSidebar: true,
            columns: 4,
            padding: 32,
            showButtonText: true,
            showVelocity: true,
            maxLines: 1,
            child: childp,
          ),
          ShadBreakpointXL() => BuildLayout(
            showSidebar: true,
            columns: 4,
            padding: 40,
            showButtonText: true,
            showVelocity: true,
            maxLines: 1,
            child: childp,
          ),
          ShadBreakpointXXL() => BuildLayout(
            showSidebar: true,
            columns: 4,
            padding: 48,
            showButtonText: true,
            showVelocity: true,
            maxLines: 1,
            child: childp,
          ),
        };
      },
    );
  }
}
