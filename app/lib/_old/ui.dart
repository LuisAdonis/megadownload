import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Download {
  final String id;
  final String name;
  final String status;
  final double? downloaded;
  final double? total;
  final double progress;
  final String? speed;
  final String? timeLeft;
  final String? error;
  final Color statusColor;

  Download({
    required this.id,
    required this.name,
    required this.status,
    this.downloaded,
    this.total,
    required this.progress,
    this.speed,
    this.timeLeft,
    this.error,
    required this.statusColor,
  });
}

class DownloadManagerScreen extends StatefulWidget {
  const DownloadManagerScreen({super.key});

  @override
  State<DownloadManagerScreen> createState() => _DownloadManagerScreenState();
}

class _DownloadManagerScreenState extends State<DownloadManagerScreen> {
  bool _isSidebarOpen = false;

  final List<Download> downloads = [
    Download(
      id: '1',
      name: 'flutter_windows_3.19.5-stable.zip',
      status: 'descargando',
      downloaded: 128.5,
      total: 980.2,
      progress: 13.1,
      speed: '3.2 MB/s',
      timeLeft: '00:04:12',
      statusColor: const Color(0xFF2563EB),
    ),
    Download(
      id: '2',
      name: 'ubuntu-24.04-desktop-amd64.iso',
      status: 'pausado',
      downloaded: 2100,
      total: 5400,
      progress: 38.8,
      speed: '0 MB/s',
      timeLeft: '--:--:--',
      statusColor: const Color(0xFFF97316),
    ),
    Download(
      id: '3',
      name: 'material-3-design-kit.fig',
      status: 'completado',
      downloaded: 45.8,
      total: 45.8,
      progress: 100,
      statusColor: const Color(0xFF16A34A),
    ),
    Download(
      id: '4',
      name: 'game-of-thrones-s08e06.mkv',
      status: 'fallido',
      progress: 67.3,
      error: 'Error de red',
      statusColor: const Color(0xFFDC2626),
    ),
  ];

  String formatSize(double mb) {
    if (mb >= 1000) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '$mb MB';
  }

  @override
  Widget build(BuildContext context) {
    return ShadResponsiveBuilder(
      builder: (context, breakpoint) {
        final sm = breakpoint >= ShadTheme.of(context).breakpoints.sm;
        final md = breakpoint >= ShadTheme.of(context).breakpoints.md;
        final lg = breakpoint >= ShadTheme.of(context).breakpoints.lg;

        return Scaffold(
          body: Stack(
            children: [
              Row(
                children: [
                  // Sidebar - Solo visible en md+
                  if (md)
                    Container(
                      width: 256,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border(
                          right: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: _buildSidebar(),
                    ),
                  // Main Content
                  Expanded(
                    child: Column(
                      children: [
                        // Header
                        _buildHeader(sm: sm, md: md, lg: lg),
                        // Main Content Area
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(
                              lg ? 32 : (md ? 24 : 16),
                            ),
                            child: Column(
                              children: [
                                // Stats Row
                                _buildStatsGrid(sm: sm, md: md, lg: lg),
                                if (md) ...[
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Vel: 12 MB/s',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                // Downloads List
                                ...downloads.map(
                                  (download) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildDownloadCard(download, md: md, lg: lg),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Mobile/Tablet Sidebar Drawer
              if (!md && _isSidebarOpen)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSidebarOpen = false;
                    });
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              if (!md && _isSidebarOpen)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 256,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(2, 0),
                        ),
                      ],
                    ),
                    child: _buildSidebar(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader({required bool sm, required bool md, required bool lg}) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(
        horizontal: lg ? 32 : (md ? 24 : 16),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
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
              if (!md)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ShadButton.ghost(
                    leading: const Icon(
                      LucideIcons.menu,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSidebarOpen = !_isSidebarOpen;
                      });
                    },
                    size: ShadButtonSize.sm,
                  ),
                ),
              Text(
                'Descargas',
                style: TextStyle(
                  fontSize: md ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              ShadButton.outline(
                leading: const Icon(
                  LucideIcons.refreshCw,
                  size: 16,
                ),
                child: md ? const Text('Actualizar') : null,
                onPressed: () {},
              ),
              SizedBox(width: md ? 16 : 8),
              ShadButton(
                leading: const Icon(
                  LucideIcons.plus,
                  size: 16,
                ),
                child: md ? const Text('Nueva descarga') : null,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid({required bool sm, required bool md, required bool lg}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar número de columnas según breakpoint
        int columns = 2; // Default mobile
        if (lg) {
          columns = 4; // Desktop
        } else if (sm) {
          columns = 2; // Tablet
        }

        final spacing = 16.0;
        final totalSpacing = spacing * (columns - 1);
        final cardWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildStatCard('Total', '24', null),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard('Activas', '4', const Color(0xFF2563EB)),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard('Completadas', '18', const Color(0xFF16A34A)),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard('Fallidas', '2', const Color(0xFFDC2626)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Column(
      children: [
        // Sidebar Header
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
                color: Colors.grey.shade900,
              ),
              const SizedBox(width: 8),
              Text(
                'Download Manager',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
        ),
        // Navigation
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildNavItem(
                icon: LucideIcons.download,
                label: 'Descargas',
                isActive: true,
              ),
              const SizedBox(height: 4),
              _buildNavItem(
                icon: LucideIcons.settings,
                label: 'Configuración',
                isActive: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE2E8F0) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              _isSidebarOpen = false;
            });
          },
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

  Widget _buildStatCard(String label, String value, Color? valueColor) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.grey.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadCard(Download download, {required bool md, required bool lg}) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        download.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: md ? 1 : 2,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildStatusBadge(download),
                          Text(
                            download.error ?? '${formatSize(download.downloaded ?? 0)} / ${formatSize(download.total ?? 0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildActionButtons(download),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: SizedBox(
                    height: 8,
                    child: LinearProgressIndicator(
                      value: download.progress / 100,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        download.statusColor,
                      ),
                    ),
                  ),
                ),
                if (download.status == 'descargando' || download.status == 'pausado')
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          download.speed ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: download.status == 'descargando' ? download.statusColor : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          download.timeLeft ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Download download) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: download.statusColor.withOpacity(0.4),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        download.status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: download.statusColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Download download) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (download.status == 'descargando') ...[
          ShadButton.ghost(
            leading: const Icon(LucideIcons.pause, size: 20),
            onPressed: () {},
            size: ShadButtonSize.sm,
          ),
          ShadButton.ghost(
            leading: const Icon(LucideIcons.x, size: 20),
            onPressed: () {},
            size: ShadButtonSize.sm,
          ),
        ] else if (download.status == 'pausado') ...[
          ShadButton.ghost(
            leading: const Icon(LucideIcons.play, size: 20),
            onPressed: () {},
            size: ShadButtonSize.sm,
          ),
          ShadButton.ghost(
            leading: const Icon(LucideIcons.x, size: 20),
            onPressed: () {},
            size: ShadButtonSize.sm,
          ),
        ] else if (download.status == 'completado') ...[
          ShadButton.ghost(
            leading: const Icon(LucideIcons.folderOpen, size: 20),
            onPressed: () {},
            size: ShadButtonSize.sm,
          ),
          ShadButton.ghost(
            leading: const Icon(LucideIcons.trash2, size: 20),
            onPressed: () {},
            size: ShadButtonSize.sm,
          ),
        ] else if (download.status == 'fallido') ...[
          ShadButton.ghost(
            leading: const Icon(LucideIcons.rotateCcw, size: 20),
            onPressed: () {},
            size: ShadButtonSize.sm,
          ),
          ShadButton.ghost(
            leading: const Icon(LucideIcons.trash2, size: 20),
            onPressed: () {},
            size: ShadButtonSize.sm,
          ),
        ],
      ],
    );
  }
}
