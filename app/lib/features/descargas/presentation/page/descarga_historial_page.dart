import 'package:app/features/descargas/domain/entities.dart';
import 'package:app/features/descargas/presentation/page/componentes/downloads_list.dart';
import 'package:app/features/descargas/presentation/providers/download_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DescargaHistorialPage extends ConsumerStatefulWidget {
  const DescargaHistorialPage({super.key});

  @override
  ConsumerState<DescargaHistorialPage> createState() => _DescargaHistorialPageState();
}

class _DescargaHistorialPageState extends ConsumerState<DescargaHistorialPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(downloadsProvider.notifier).initHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(downloadsProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _StatsBar(
            stats: data.stats,
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: data.downloadsHistory.length,
              itemBuilder: (context, index) {
                final datas = data.downloadsHistory[index];
                final name = datas.fileName;
                final size = DownloadsList.formatBytesStatic(datas.fileSize);
                final done = DownloadsList.formatBytesStatic(datas.downloadedSize);
                final status = datas.status;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4, top: 4, left: 8, right: 8),
                  child: ShadCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text('$done / $size', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                              Text(datas.provider),
                            ],
                          ),
                        ),
                        Container(
                          width: 100,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: _statusColor(status, context).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                          child: Text(status, style: TextStyle(color: _statusColor(status, context), fontSize: 12)),
                        ),
                        if (status == 'failed') ...[
                          ShadButton.ghost(
                            leading: Icon(LucideIcons.refreshCcw),
                            size: ShadButtonSize.sm,

                            onPressed: () {
                              ref.read(downloadsProvider.notifier).addUrl(url: datas.url);
                            },
                          ),
                        ] else ...[
                          ShadButton.ghost(
                            leading: Icon(LucideIcons.check),
                            size: ShadButtonSize.sm,

                            onPressed: () {},
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status, BuildContext context) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'downloading':
        return Theme.of(context).colorScheme.primary;
      case 'paused':
        return Colors.orange;
      case 'failed':
      case 'quota_exceeded':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _StatsBar extends StatelessWidget {
  final StatsModel stats;
  const _StatsBar({required this.stats});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: Colors.grey.shade800);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          _chip(context, 'Total', stats.total.toString()),
          _chip(context, 'Activas', (stats.downloading + stats.queued).toString()),
          _chip(context, 'Completadas', stats.completed.toString()),
          _chip(context, 'Fallidas', stats.failed.toString()),
          const Spacer(),
          const Icon(Icons.speed, size: 18),
          const SizedBox(width: 6),
          Text('Vel: ${_formatBytes(stats.totalSpeed.toInt())}/s', style: style),
        ],
      ),
    );
  }

  Widget _chip(BuildContext ctx, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double v = bytes.toDouble();
    int i = 0;
    while (v >= 1024 && i < units.length - 1) {
      v /= 1024;
      i++;
    }
    return '${v.toStringAsFixed(v >= 10 || v == v.roundToDouble() ? 0 : 1)} ${units[i]}';
  }
}
