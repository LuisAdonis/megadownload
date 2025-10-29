import 'package:app/features/descargas/presentation/providers/download_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FormUrl extends ConsumerStatefulWidget {
  const FormUrl({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FormUrlState();
}

class _FormUrlState extends ConsumerState<FormUrl> {
  final ctlForm = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: Text("Nueva Url"),
      actions: [
        ShadIconButton(
          icon: Icon(LucideIcons.plus),
          onPressed: () => ref.read(downloadsProvider.notifier).addUrl(url: ctlForm.text),
        ),
      ],
      child: Column(
        children: [
          ShadInputFormField(
            controller: ctlForm,
          ),
        ],
      ),
    );
  }
}
