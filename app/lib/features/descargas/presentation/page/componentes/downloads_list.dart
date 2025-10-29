import 'package:app/features/descargas/domain/entities.dart';
import 'package:app/features/descargas/presentation/providers/download_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadsList extends ConsumerWidget {
  const DownloadsList({super.key, required this.items});
  final List<DownloadModel> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const Center(child: Text('Sin descargas aún'));
    }
    return ListView.separated(
      itemBuilder: (_, i) {
        final d = items[i];
        final pct = (d.progress).clamp(0, 100);
        // final humanSize = _formatBytes(d.fileSize);
        final humanSpeed = d.speed > 0 ? '${_formatBytes(d.speed.toInt())}/s' : '-';
        final eta = d.timeRemaining != null ? _formatEta(d.timeRemaining!) : '-';
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RealtimeHeader(id: d.id, fallbackName: d.fileName, fallbackStatus: d.status, fallbackFileSize: d.fileSize, fallbackDownloaded: d.downloadedSize),
                const SizedBox(height: 10),
                _RealtimeProgressBar(id: d.id, fallbackPct: double.parse(pct.toString())),
                const SizedBox(height: 8),
                _RealtimeInfoRow(id: d.id, fallbackSpeed: humanSpeed, fallbackEta: eta),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Pausar',
                      onPressed: d.status == 'downloading'
                          ? () async {
                              await ref.read(downloadsProvider.notifier).pause(id: d.id);
                              // ref.invalidate(downloadsProvider);
                            }
                          : null,
                      icon: const Icon(Icons.pause_circle),
                    ),
                    IconButton(
                      tooltip: 'Reanudar',
                      onPressed: d.status == 'paused'
                          ? () async {
                              // await ref.read(downloadsRepositoryProvider).resume(d.id);
                              // ref.invalidate(downloadsListProvider);
                            }
                          : null,
                      icon: const Icon(Icons.play_circle),
                    ),
                    IconButton(
                      tooltip: 'Cancelar',
                      onPressed: d.status != 'completed'
                          ? () async {
                              // await ref.read(downloadsRepositoryProvider).cancel(d.id);
                              // ref.invalidate(downloadsListProvider);
                            }
                          : null,
                      icon: const Icon(Icons.cancel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: items.length,
    );
  }

  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double v = bytes.toDouble();
    int i = 0;
    while (v >= 1024 && i < units.length - 1) {
      v /= 1024;
      i++;
    }
    return '${v.toStringAsFixed(v >= 10 || v == v.roundToDouble() ? 0 : 1)} ${units[i]}';
  }

  String _formatEta(int seconds) {
    final m = Duration(seconds: seconds);
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(m.inHours);
    final min = two(m.inMinutes.remainder(60));
    final s = two(m.inSeconds.remainder(60));
    return '$h:$min:$s';
  }

  // Static helpers for use from other widgets (e.g., SSE row)
  static String _formatBytesStatic(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double v = bytes.toDouble();
    int i = 0;
    while (v >= 1024 && i < units.length - 1) {
      v /= 1024;
      i++;
    }
    return '${v.toStringAsFixed(v >= 10 || v == v.roundToDouble() ? 0 : 1)} ${units[i]}';
  }

  static String _formatEtaStatic(int seconds) {
    final m = Duration(seconds: seconds);
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(m.inHours);
    final min = two(m.inMinutes.remainder(60));
    final s = two(m.inSeconds.remainder(60));
    return '$h:$min:$s';
  }
}

class _RealtimeProgressBar extends ConsumerWidget {
  final String id;
  final double fallbackPct;
  const _RealtimeProgressBar({required this.id, required this.fallbackPct});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sse = ref.watch(downloadProgressProvider(id));
    return sse.when(
      data: (d) {
        final pct = d.progress.isFinite ? (d.progress / 100).clamp(0, 1) : 0.0;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: double.tryParse(pct.toString()), minHeight: 8, backgroundColor: Colors.grey.shade200),
        );
      },
      loading: () => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(value: fallbackPct.isFinite ? fallbackPct / 100 : 0, minHeight: 8, backgroundColor: Colors.grey.shade200),
      ),
      error: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(value: fallbackPct.isFinite ? fallbackPct / 100 : 0, minHeight: 8, backgroundColor: Colors.grey.shade200),
      ),
    );
  }
}

class _RealtimeInfoRow extends ConsumerWidget {
  final String id;
  final String fallbackSpeed;
  final String fallbackEta;
  const _RealtimeInfoRow({required this.id, required this.fallbackSpeed, required this.fallbackEta});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sse = ref.watch(downloadProgressProvider(id));
    return sse.when(
      data: (d) {
        final speed = d.speed > 0 ? '${DownloadsList._formatBytesStatic(d.speed.toInt())}/s' : '-';
        final eta = d.timeRemaining != null ? DownloadsList._formatEtaStatic(d.timeRemaining!) : '-';
        return Row(
          children: [
            Icon(Icons.speed, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 6),
            Text(speed, style: TextStyle(color: Colors.grey.shade700)),
            const Spacer(),
            Icon(Icons.schedule, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 6),
            Text(eta, style: TextStyle(color: Colors.grey.shade700)),
          ],
        );
      },
      loading: () => Row(
        children: [
          Icon(Icons.speed, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(fallbackSpeed, style: TextStyle(color: Colors.grey.shade700)),
          const Spacer(),
          Icon(Icons.schedule, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(fallbackEta, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
      error: (_, __) => Row(
        children: [
          Icon(Icons.speed, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(fallbackSpeed, style: TextStyle(color: Colors.grey.shade700)),
          const Spacer(),
          Icon(Icons.schedule, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(fallbackEta, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}

class _RealtimeHeader extends ConsumerWidget {
  final String id;
  final String fallbackName;
  final String fallbackStatus;
  final int fallbackFileSize;
  final int fallbackDownloaded;
  const _RealtimeHeader({required this.id, required this.fallbackName, required this.fallbackStatus, required this.fallbackFileSize, required this.fallbackDownloaded});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sse = ref.watch(downloadProgressProvider(id));

    return sse.when(
      data: (d) {
        final status = d.status;
        final name = d.fileName;
        final size = DownloadsList._formatBytesStatic(d.fileSize);
        final done = DownloadsList._formatBytesStatic(d.downloadedSize);
        return Row(
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
                  const SizedBox(height: 4),
                  Text('$done / $size', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _statusColor(status, context).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              child: Text(status, style: TextStyle(color: _statusColor(status, context), fontSize: 12)),
            ),
          ],
        );
      },
      loading: () {
        final status = fallbackStatus;
        final size = DownloadsList._formatBytesStatic(fallbackFileSize);
        final done = DownloadsList._formatBytesStatic(fallbackDownloaded);
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fallbackName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text('$done / $size', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _statusColor(status, context).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              child: Text(status, style: TextStyle(color: _statusColor(status, context), fontSize: 12)),
            ),
          ],
        );
      },
      error: (_, __) {
        final status = fallbackStatus;
        final size = DownloadsList._formatBytesStatic(fallbackFileSize);
        final done = DownloadsList._formatBytesStatic(fallbackDownloaded);
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fallbackName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text('$done / $size', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _statusColor(status, context).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              child: Text(status, style: TextStyle(color: _statusColor(status, context), fontSize: 12)),
            ),
          ],
        );
      },
    );
  }
}
