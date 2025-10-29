import 'package:app/features/descargas/presentation/page/componentes/downloads_list.dart';
import 'package:app/features/descargas/presentation/providers/download_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DescargasPage extends ConsumerWidget {
  const DescargasPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final data = ref.watch(downloadsProvider);
    return ShadCard(
      child: Column(
        children: [
          if (data.isLoading)
            Text("cargando...")
          else if (data.hasError)
            Text("error: ${data.errorMessage} ${data.downloads.length} ${data.downloadsHistory.length}")
          else if (data.hasData)
            Expanded(
              child: DownloadsList(items: data.downloads),
            )
          else
            Text("Sin descargas activas"),
        ],
      ),
    );
  }
}
