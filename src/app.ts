import express from 'express';
import { DatabaseService } from './services/database.service';
import { UniversalDownloadManager  } from './services/download.manager';
import { DownloadController } from './controllers/download.controller';
import { createDownloadRoutes } from './routes/download.routes';
import { config } from './config/config';
import dotenv from 'dotenv';
export async function createApp() {
  dotenv.config();
  const app = express();
  app.use(express.json());

  // Conectar a MongoDB
  const dbService = DatabaseService.getInstance();
  await dbService.connect(config.mongoUri);

  // Inicializar gestor de descargas
  const downloadManager = new UniversalDownloadManager ({
    maxConcurrent: config.maxConcurrent,
    downloadPath: config.downloadPath
  });

  await downloadManager.restoreFromDatabase();

  // Configurar controlador y rutas
  const downloadController = new DownloadController(downloadManager);
  const routes = createDownloadRoutes(downloadController);
  
  app.use('/api', routes);

  // Health check
  app.get('/health', (req, res) => {
    res.json({ 
      status: 'ok', 
      database: dbService.getConnectionStatus(),
            supportedProviders: ['mega', '1fichier']

    });
  });

  return app;
}