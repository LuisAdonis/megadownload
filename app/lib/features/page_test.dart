import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PageTest extends StatelessWidget {
  const PageTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ShadCard(child: Text("tEst")),
    );
  }
}
