import { EventEmitter } from 'events';
import * as fs from 'fs/promises'; // ✅ Usar versión asíncrona
import * as path from 'path';
import { Download } from '../models/Download.model';
import { DownloadInfo, DownloadOptions, ManagerOptions, DownloadStats } from '../types';
import { DownloaderFactory } from './downloaders/factory.downloader';
import { BaseDownloader } from './downloaders/base.downloader';

export class UniversalDownloadManager extends EventEmitter {
  private downloads: Map<string, DownloadInfo> = new Map();
  private activeDownloads: Map<string, BaseDownloader> = new Map();
  private queue: string[] = [];
  private maxConcurrent: number = 2;
  private defaultDownloadPath: string = './downloads';
  private saveInterval: NodeJS.Timeout | null = null;
  
  // ✅ Mejoras de rendimiento
  private pendingSaves: Set<string> = new Set();
  private batchSaveTimeout: NodeJS.Timeout | null = null;
  private readonly BATCH_SAVE_DELAY = 2000; // 2 segundos
  private readonly PROGRESS_THROTTLE = 1000; // 1 segundo entre emisiones

  constructor(options?: ManagerOptions) {
    super();
    if (options?.maxConcurrent) this.maxConcurrent = options.maxConcurrent;
    if (options?.downloadPath) this.defaultDownloadPath = options.downloadPath;

    this.initializeDownloadPath();
    
    // ✅ Reducir frecuencia de guardado de 5s a 30s
    this.saveInterval = setInterval(() => {
      this.flushPendingSaves();
    }, 30000);
  }

  private async initializeDownloadPath(): Promise<void> {
    try {
      await fs.access(this.defaultDownloadPath);
    } catch {
      await fs.mkdir(this.defaultDownloadPath, { recursive: true });
    }
  }

  async restoreFromDatabase(): Promise<void> {
    try {
      const downloads = await Download.find({
        status: { $in: ['queued', 'downloading', 'paused'] }
      }).lean(); // ✅ Usar .lean() para mejor rendimiento

      for (const doc of downloads) {
        const downloadInfo: DownloadInfo = {
          id: doc.downloadId,
          url: doc.url,
          fileName: doc.fileName,
          fileSize: doc.fileSize,
          downloadedSize: doc.downloadedSize,
          status: doc.status,
          progress: doc.progress,
          speed: 0,
          timeRemaining: doc.timeRemaining,
          error: doc.error || undefined,
          startTime: doc.startTime || undefined,
          endTime: doc.endTime || undefined,
          createdAt: doc.createdAt,
          provider: doc.provider as any
        };

        this.downloads.set(downloadInfo.id, downloadInfo);

        if (downloadInfo.status === 'queued' || downloadInfo.status === 'downloading') {
          downloadInfo.status = 'queued';
          this.queue.push(downloadInfo.id);
        }
      }

      console.log(`📦 Restauradas ${downloads.length} descargas desde MongoDB`);
      this.processQueue();
    } catch (error) {
      console.error('Error restaurando descargas:', error);
    }
  }

  // ✅ Guardado en lotes con debounce
  private scheduleSave(downloadId: string): void {
    this.pendingSaves.add(downloadId);

    if (this.batchSaveTimeout) {
      clearTimeout(this.batchSaveTimeout);
    }

    this.batchSaveTimeout = setTimeout(() => {
      this.flushPendingSaves();
    }, this.BATCH_SAVE_DELAY);
  }

  // ✅ Guardar múltiples descargas en una sola operación
  private async flushPendingSaves(): Promise<void> {
    if (this.pendingSaves.size === 0) return;

    const idsToSave = Array.from(this.pendingSaves);
    this.pendingSaves.clear();

    try {
      const bulkOps = idsToSave
        .map(id => this.downloads.get(id))
        .filter(Boolean)
        .map(downloadInfo => ({
          updateOne: {
            filter: { downloadId: downloadInfo!.id },
            update: {
              $set: {
                downloadId: downloadInfo!.id,
                url: downloadInfo!.url,
                fileName: downloadInfo!.fileName,
                fileSize: downloadInfo!.fileSize,
                downloadedSize: downloadInfo!.downloadedSize,
                status: downloadInfo!.status,
                progress: downloadInfo!.progress,
                speed: downloadInfo!.speed,
                timeRemaining: downloadInfo!.timeRemaining || 0,
                error: downloadInfo!.error || null,
                startTime: downloadInfo!.startTime || null,
                endTime: downloadInfo!.endTime || null,
                createdAt: downloadInfo!.createdAt,
                updatedAt: Date.now(),
                provider: downloadInfo!.provider
              }
            },
            upsert: true
          }
        }));

      if (bulkOps.length > 0) {
        await Download.bulkWrite(bulkOps, { ordered: false });
      }
    } catch (error) {
      console.error('Error en guardado por lotes:', error);
    }
  }

  // ✅ Guardado inmediato solo para estados críticos
  private async saveToDatabase(downloadInfo: DownloadInfo, immediate = false): Promise<void> {
    if (immediate) {
      try {
        await Download.findOneAndUpdate(
          { downloadId: downloadInfo.id },
          {
            downloadId: downloadInfo.id,
            url: downloadInfo.url,
            fileName: downloadInfo.fileName,
            fileSize: downloadInfo.fileSize,
            downloadedSize: downloadInfo.downloadedSize,
            status: downloadInfo.status,
            progress: downloadInfo.progress,
            speed: downloadInfo.speed,
            timeRemaining: downloadInfo.timeRemaining || 0,
            error: downloadInfo.error || null,
            startTime: downloadInfo.startTime || null,
            endTime: downloadInfo.endTime || null,
            createdAt: downloadInfo.createdAt,
            updatedAt: Date.now(),
            provider: downloadInfo.provider
          },
          { upsert: true, new: true }
        );
      } catch (error) {
        console.error('Error guardando descarga:', error);
      }
    } else {
      // ✅ Programar guardado por lotes
      this.scheduleSave(downloadInfo.id);
    }
  }

  private async deleteFromDatabase(id: string): Promise<void> {
    try {
      await Download.deleteOne({ downloadId: id });
    } catch (error) {
      console.error('Error eliminando descarga:', error);
    }
  }

  async addDownload(url: string, options?: DownloadOptions): Promise<string> {
    const id = this.generateId();
    const provider = DownloaderFactory.detectProvider(url);
    
    if (!provider) {
      throw new Error('URL no soportada. Use Mega o 1fichier.');
    }

    const downloadInfo: DownloadInfo = {
      id,
      url,
      fileName: 'Cargando...',
      fileSize: 0,
      downloadedSize: 0,
      status: 'queued',
      progress: 0,
      speed: 0,
      createdAt: Date.now(),
      provider
    };

    this.downloads.set(id, downloadInfo);
    this.queue.push(id);

    // ✅ Guardado inmediato solo al agregar
    await this.saveToDatabase(downloadInfo, true);

    this.emit('downloadAdded', downloadInfo);
    this.processQueue();

    return id;
  }

  private async processQueue(): Promise<void> {
    const activeCount = this.activeDownloads.size;
    if (activeCount >= this.maxConcurrent || this.queue.length === 0) {
      return;
    }

    const id = this.queue.shift();
    if (!id) return;

    const downloadInfo = this.downloads.get(id);
    if (!downloadInfo) return;

    await this.startDownload(id);
    this.processQueue();
  }

  private async startDownload(id: string): Promise<void> {
    const downloadInfo = this.downloads.get(id);
    if (!downloadInfo) return;

    try {
      // ✅ Usar versión asíncrona
      try {
        await fs.access(this.defaultDownloadPath, fs.constants.W_OK);
      } catch {
        throw new Error(`No se puede escribir en ${this.defaultDownloadPath}`);
      }

      downloadInfo.status = 'downloading';
      downloadInfo.startTime = Date.now();
      await this.saveToDatabase(downloadInfo, true); // ✅ Guardado inmediato
      this.emit('downloadStarted', downloadInfo);

      const { downloader } = DownloaderFactory.createDownloader(downloadInfo.url);
      this.activeDownloads.set(id, downloader);

      try {
        const metadata = await downloader.getFileMetadata(downloadInfo.url);
        downloadInfo.fileName = this.sanitizeFileName(metadata.fileName);
        downloadInfo.fileSize = metadata.fileSize;
        await this.saveToDatabase(downloadInfo, true);
        this.emit('fileInfoLoaded', downloadInfo);
      } catch (error) {
        console.warn('No se pudo obtener metadata:', error);
        const urlParts = downloadInfo.url.split('/');
        let fileName = urlParts[urlParts.length - 1] || `file_${Date.now()}`;
        if (fileName.includes('?')) fileName = fileName.split('?')[0];
        if (!fileName.includes('.')) fileName += '.download';
        downloadInfo.fileName = this.sanitizeFileName(fileName);
      }

      const downloadPath = path.join(this.defaultDownloadPath, downloadInfo.fileName);

      let lastUpdate = Date.now();
      let lastDownloadedSize = 0;
      let lastEmit = Date.now(); // ✅ Control de emisión de eventos

      // ✅ Throttling de eventos de progreso
      downloader.on('progress', (progressData: any) => {
        downloadInfo.downloadedSize = progressData.downloadedSize;
        downloadInfo.fileSize = progressData.totalSize;
        
        if (downloadInfo.fileSize > 0) {
          downloadInfo.progress = (downloadInfo.downloadedSize / downloadInfo.fileSize) * 100;
        } else {
          downloadInfo.progress = 0;
        }

        const now = Date.now();
        
        // Calcular velocidad cada segundo
        if (now - lastUpdate >= 1000) {
          const timeDiff = (now - lastUpdate) / 1000;
          const sizeDiff = downloadInfo.downloadedSize - lastDownloadedSize;
          downloadInfo.speed = sizeDiff / timeDiff;

          if (downloadInfo.speed > 0 && downloadInfo.fileSize > 0) {
            const remaining = downloadInfo.fileSize - downloadInfo.downloadedSize;
            downloadInfo.timeRemaining = Math.round(remaining / downloadInfo.speed);
          } else {
            downloadInfo.timeRemaining = undefined;
          }

          lastUpdate = now;
          lastDownloadedSize = downloadInfo.downloadedSize;
        }

        // ✅ Emitir eventos solo cada PROGRESS_THROTTLE ms (1 segundo)
        if (now - lastEmit >= this.PROGRESS_THROTTLE) {
          this.emit('downloadProgress', downloadInfo);
          lastEmit = now;
          
          // ✅ Programar guardado (no inmediato)
          this.scheduleSave(downloadInfo.id);
        }
      });

      downloader.on('error', (error: Error) => {
        this.activeDownloads.delete(id);
        this.handleDownloadError(id, error);
      });

      downloader.on('complete', async () => {
        this.activeDownloads.delete(id);
        downloadInfo.status = 'completed';
        downloadInfo.progress = 100;
        downloadInfo.endTime = Date.now();
        downloadInfo.speed = 0;
        downloadInfo.timeRemaining = 0;

        // ✅ Guardado inmediato al completar
        await this.saveToDatabase(downloadInfo, true);
        this.emit('downloadCompleted', downloadInfo);
        this.processQueue();
      });

      await downloader.download(downloadInfo.url, downloadPath);

    } catch (error) {
      this.handleDownloadError(id, error as Error);
    }
  }

  async pauseDownload(id: string): Promise<boolean> {
    const downloadInfo = this.downloads.get(id);
    if (!downloadInfo || downloadInfo.status !== 'downloading') {
      return false;
    }

    const downloader = this.activeDownloads.get(id);
    if (downloader) {
      downloader.abort();
      this.activeDownloads.delete(id);
    }

    downloadInfo.status = 'paused';
    downloadInfo.speed = 0;
    await this.saveToDatabase(downloadInfo, true); // ✅ Inmediato
    this.emit('downloadPaused', downloadInfo);

    this.processQueue();
    return true;
  }

  async resumeDownload(id: string): Promise<boolean> {
    let downloadInfo = this.downloads.get(id);

    if (!downloadInfo) {
      const doc = await Download.findOne({ downloadId: id }).lean();
      if (doc) {
        downloadInfo = {
          id: doc.downloadId,
          url: doc.url,
          fileName: doc.fileName,
          fileSize: doc.fileSize,
          downloadedSize: doc.downloadedSize,
          status: doc.status,
          progress: doc.progress,
          speed: 0,
          timeRemaining: doc.timeRemaining,
          error: doc.error || undefined,
          startTime: doc.startTime || undefined,
          endTime: doc.endTime || undefined,
          createdAt: doc.createdAt,
          provider: doc.provider as any
        };
        this.downloads.set(id, downloadInfo);
      }
    }

    if (!downloadInfo) return false;

    const resumableStatuses = new Set(['paused', 'failed', 'quota_exceeded']);
    if (!resumableStatuses.has(downloadInfo.status)) {
      return false;
    }

    downloadInfo.status = 'queued';
    downloadInfo.speed = 0;
    await this.saveToDatabase(downloadInfo, true); // ✅ Inmediato
    this.queue.unshift(id);
    this.processQueue();
    return true;
  }

  async cancelDownload(id: string): Promise<boolean> {
    const downloadInfo = this.downloads.get(id);
    if (!downloadInfo) return false;

    const downloader = this.activeDownloads.get(id);
    if (downloader) {
      downloader.abort();
      this.activeDownloads.delete(id);
    }

    const filePath = path.join(this.defaultDownloadPath, downloadInfo.fileName);
    
    // ✅ Usar versión asíncrona
    try {
      await fs.unlink(filePath);
    } catch (error) {
      // Archivo no existe o ya fue eliminado
    }

    const queueIndex = this.queue.indexOf(id);
    if (queueIndex > -1) {
      this.queue.splice(queueIndex, 1);
    }

    this.downloads.delete(id);
    await this.deleteFromDatabase(id);
    this.emit('downloadCancelled', { id });

    this.processQueue();
    return true;
  }

  getDownload(id: string): DownloadInfo | null {
    return this.downloads.get(id) || null;
  }

  getAllDownloads(): DownloadInfo[] {
    return Array.from(this.downloads.values());
  }

  async getStats(): Promise<DownloadStats> {
    // ✅ Usar agregación de MongoDB para mejor rendimiento
    const pipeline = [
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
          totalSpeed: {
            $sum: {
              $cond: [{ $eq: ['$status', 'downloading'] }, '$speed', 0]
            }
          }
        }
      }
    ];

    const results = await Download.aggregate(pipeline);
    
    const stats: DownloadStats = {
      total: 0,
      queued: 0,
      downloading: 0,
      paused: 0,
      completed: 0,
      failed: 0,
      quota_exceeded: 0,
      totalSpeed: 0
    };

    results.forEach(result => {
      stats.total += result.count;
      const status = result._id as keyof DownloadStats;
      if (status in stats && status !== 'total' && status !== 'totalSpeed') {
        (stats[status] as number) = result.count;
      }
      stats.totalSpeed += result.totalSpeed || 0;
    });

    return stats;
  }

  private async handleDownloadError(id: string, error: Error): Promise<void> {
    const downloadInfo = this.downloads.get(id);
    if (!downloadInfo) return;

    if (error.message.includes('quota') || 
        error.message.includes('bandwidth') || 
        error.message.includes('límite')) {
      downloadInfo.status = 'quota_exceeded';
      downloadInfo.error = 'Límite alcanzado. Reintenta más tarde.';
    } else {
      downloadInfo.status = 'failed';
      downloadInfo.error = error.message;
    }

    downloadInfo.speed = 0;
    await this.saveToDatabase(downloadInfo, true); // ✅ Inmediato
    this.emit('downloadFailed', downloadInfo);
    this.processQueue();
  }

  private generateId(): string {
    return `download_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  private sanitizeFileName(originalName: string): string {
    const base = path.basename(originalName || '');
    let cleaned = base.replace(/[\/:*?"<>|]/g, '_').trim();
    if (!cleaned) cleaned = `file_${Date.now()}`;
    if (cleaned.length > 180) {
      const extIndex = cleaned.lastIndexOf('.');
      if (extIndex > 0 && extIndex < 140) {
        const name = cleaned.slice(0, 140);
        const ext = cleaned.slice(extIndex);
        cleaned = name + ext;
      } else {
        cleaned = cleaned.slice(0, 180);
      }
    }
    return cleaned;
  }

  async destroy(): Promise<void> {
    if (this.saveInterval) {
      clearInterval(this.saveInterval);
    }
    if (this.batchSaveTimeout) {
      clearTimeout(this.batchSaveTimeout);
    }
    // ✅ Guardar pendientes antes de cerrar
    await this.flushPendingSaves();
  }
}