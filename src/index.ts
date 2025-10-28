import { createApp } from './app';
import { config } from './config/config';
import dotenv from 'dotenv';
async function startServer() {
  try {
    dotenv.config();
    const app = await createApp();
    app.listen(config.port, () => {
      console.log(`🚀 API Universal de Descargas en http://localhost:${config.port}`);
      console.log(`📦 Providers soportados: Mega, 1fichier`);
      // console.log(`  POST   /api/downloads                - Agregar descarga`);
      // console.log(`  GET    /api/downloads                - Listar activas`);
      // console.log(`  GET    /api/downloads/history        - Historial completo`);
      // console.log(`  GET    /api/downloads/:id            - Info específica`);
      // console.log(`  PUT    /api/downloads/:id/pause      - Pausar`);
      // console.log(`  PUT    /api/downloads/:id/resume     - Reanudar`);
      // console.log(`  DELETE /api/downloads/:id            - Cancelar`);
      // console.log(`  DELETE /api/downloads/history/:id    - Eliminar historial`);
      // console.log(`  DELETE /api/downloads/history/all    - Eliminar todo el historial`);
      // console.log(`  GET    /api/stats                    - Estadísticas`);
      // console.log(`  GET    /api/downloads/:id/stream     - Stream progreso`);
      // console.log(`  GET    /health                       - Health check`);
    });
  } catch (error) {
    console.error('❌ Error iniciando servidor:', error);
    process.exit(1);
  }
}

startServer();