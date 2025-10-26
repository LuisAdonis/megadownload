import { Request, Response } from 'express';
import { UniversalDownloadManager } from '../services/download.manager';
import { Download } from '../models/Download.model';

export class DownloadController {
  constructor(private downloadManager: UniversalDownloadManager) { }

  addDownload = async (req: Request, res: Response): Promise<void> => {
    const { url, priority } = req.body;

    if (!url) {
      res.status(400).json({ error: 'URL es requerida' });
      return;
    }

    // Validar que sea Mega o 1fichier
    const isMega = url.includes('mega.nz') || url.includes('mega.co.nz');
    const isFichier = url.includes('1fichier.com');

    if (!isMega && !isFichier) {
      res.status(400).json({
        error: 'URL inválida. Solo se soporta Mega y 1fichier',
        supportedProviders: ['mega.nz', '1fichier.com']
      });
      return;
    }
    try {
      const existing = await Download.findOne({
        url: url,
      });
      if (existing) {
        res.status(409).json({
          error: 'El archivo ya ha sido descargado previamente',
          downloadId: existing.downloadId,
          stautus:existing.status
        });
        return;
      }

    } catch (error) {
      res.status(500).json({ error: (error as Error).message });

    }


    try {
      const id = await this.downloadManager.addDownload(url, { priority });
      res.status(201).json({
        message: 'Descarga agregada exitosamente',
        downloadId: id,
        provider: isMega ? 'mega' : '1fichier'
      });
    } catch (error) {
      res.status(500).json({ error: (error as Error).message });
    }
  };

  getAllDownloads = (req: Request, res: Response): void => {
    const { status } = req.query;
    let downloads = this.downloadManager.getAllDownloads();

    if (status) {
      downloads = downloads.filter(d => d.status === status);
    }
    // else{
    //     downloads = this.downloadManager.getAllDownloads();

    // }

    res.json({ downloads,status });
  };

  getDownloadHistory = async (req: Request, res: Response): Promise<void> => {
    try {
      const { status, limit = 50 } = req.query;
      const query = status ? { status } : {};

      const downloads = await Download.find(query)
        .sort({ createdAt: -1 })
        .limit(Number(limit));

      res.json({ downloads });
    } catch (error) {
      res.status(500).json({ error: (error as Error).message });
    }
  };

  getDownloadById = (req: Request, res: Response): void => {
    const { id } = req.params;
    const download = this.downloadManager.getDownload(id);

    if (!download) {
      res.status(404).json({ error: 'Descarga no encontrada' });
      return;
    }

    res.json({ download });
  };

  pauseDownload = async (req: Request, res: Response): Promise<void> => {
    const { id } = req.params;
    const success = await this.downloadManager.pauseDownload(id);

    if (!success) {
      res.status(400).json({ error: 'No se pudo pausar la descarga' });
      return;
    }

    res.json({ message: 'Descarga pausada' });
  };

  resumeDownload = async (req: Request, res: Response): Promise<void> => {
    const { id } = req.params;
    const success = await this.downloadManager.resumeDownload(id);

    if (!success) {
      res.status(400).json({ error: 'No se pudo reanudar la descarga' });
      return;
    }

    res.json({ message: 'Descarga reanudada' });
  };

  cancelDownload = async (req: Request, res: Response): Promise<void> => {
    const { id } = req.params;
    const success = await this.downloadManager.cancelDownload(id);

    if (!success) {
      res.status(404).json({ error: 'Descarga no encontrada' });
      return;
    }

    res.json({ message: 'Descarga cancelada' });
  };

  deleteFromHistory = async (req: Request, res: Response): Promise<void> => {
    try {
      const { id } = req.params;
      await Download.deleteOne({ downloadId: id });
      res.json({ message: 'Descarga eliminada del historial' });
    } catch (error) {
      res.status(500).json({ error: (error as Error).message });
    }
  };
 deleteFromHistoryall = async (req: Request, res: Response): Promise<void> => {
    try {
      await Download.deleteMany();
      res.json({ message: 'Todo el historial de descargas ha sido eliminado' });
    } catch (error) {
      res.status(500).json({ error: (error as Error).message });
    }
  };
  getStats = async (req: Request, res: Response): Promise<void> => {
    const stats = await this.downloadManager.getStats();
    res.json({ stats});
  };

  streamProgress = (req: Request, res: Response): void => {
    const { id } = req.params;

    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    const sendUpdate = (data: any) => {
      if (data.id === id) {
        res.write(`data: ${JSON.stringify(data)}\n\n`);
      }
    };

    this.downloadManager.on('downloadProgress', sendUpdate);
    this.downloadManager.on('downloadCompleted', sendUpdate);
    this.downloadManager.on('downloadFailed', sendUpdate);

    req.on('close', () => {
      this.downloadManager.off('downloadProgress', sendUpdate);
      this.downloadManager.off('downloadCompleted', sendUpdate);
      this.downloadManager.off('downloadFailed', sendUpdate);
    });
  };
}