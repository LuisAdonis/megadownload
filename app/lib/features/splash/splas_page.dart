import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SplasPage extends StatelessWidget {
  const SplasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      child: Column(
        children: [
          ShadButton(
            onPressed: () {
              context.push("/dashboard");
            },
          ),
          Text("continuar"),
        ],
      ),
    );
  }
}
