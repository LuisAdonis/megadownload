import { Router } from 'express';
import { DownloadController } from '../controllers/download.controller';

export function createDownloadRoutes(controller: DownloadController): Router {
  const router = Router();

  router.post('/downloads', controller.addDownload);
  router.get('/downloads', controller.getAllDownloads);
  router.get('/downloads/history', controller.getDownloadHistory);
  router.delete('/downloads/history/all', controller.deleteFromHistoryall);
  router.get('/downloads/:id', controller.getDownloadById);
  router.put('/downloads/:id/pause', controller.pauseDownload);
  router.put('/downloads/:id/resume', controller.resumeDownload);
  router.delete('/downloads/:id', controller.cancelDownload);
  router.delete('/downloads/history/:id', controller.deleteFromHistory);
  router.get('/stats', controller.getStats);
  router.get('/downloads/:id/stream', controller.streamProgress);

  return router;
}