import axios from 'axios';
import * as fs from 'fs';
import * as cheerio from 'cheerio';
import { BaseDownloader, FileMetadata } from './base.downloader';

export class FichierDownloader extends BaseDownloader {
  private abortController: AbortController | null = null;
async getFileMetadata(url: string): Promise<FileMetadata> {
    try {
      const pageResponse = await axios.get(url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
      });

      const $ = cheerio.load(pageResponse.data);

      // Extraer nombre del archivo
      let fileName = $('.btn-general').attr('title') || '';
      
      if (!fileName) {
        // Intentar extraer del texto visible
        fileName = $('.text-center').first().text().trim() || '';
      }

      if (!fileName) {
        fileName = 'archivo_1fichier';
      }

      // Extraer tamaño si está disponible
      let fileSize = 0;
      const sizeText = $('.text-center').text();
      const sizeMatch = sizeText.match(/(\d+(?:\.\d+)?)\s*(MB|GB|KB)/i);
      if (sizeMatch) {
        const size = parseFloat(sizeMatch[1]);
        const unit = sizeMatch[2].toUpperCase();
        if (unit === 'KB') fileSize = size * 1024;
        else if (unit === 'MB') fileSize = size * 1024 * 1024;
        else if (unit === 'GB') fileSize = size * 1024 * 1024 * 1024;
      }

      return {
        fileName: fileName || 'archivo_1fichier',
        fileSize
      };
    } catch (error) {
      throw new Error(`Error obteniendo metadata de 1fichier: ${(error as Error).message}`);
    }
  }
  async download(url: string, downloadPath: string): Promise<void> {
    return new Promise(async (resolve, reject) => {
      try {
        // Paso 1: Obtener la página de descarga
        const pageResponse = await axios.get(url, {
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
          }
        });

        const $ = cheerio.load(pageResponse.data);

        // Extraer información del archivo
        const fileName = $('.btn-general').attr('title') || 'file';
        
        // Buscar el enlace de descarga directo
        let downloadUrl = '';
        
        // 1fichier puede tener el enlace en diferentes lugares
        const downloadButton = $('a.btn-general[href*="https://"]');
        if (downloadButton.length > 0) {
          downloadUrl = downloadButton.attr('href') || '';
        }

        if (!downloadUrl) {
          // Intentar extraer de scripts
          const scripts = $('script').toArray();
          for (const script of scripts) {
            const content = $(script).html() || '';
            const match = content.match(/https:\/\/[^"'\s]+/);
            if (match && match[0].includes('1fichier')) {
              downloadUrl = match[0];
              break;
            }
          }
        }

        if (!downloadUrl) {
          throw new Error('No se pudo extraer el enlace de descarga de 1fichier');
        }

        // Paso 2: Hacer request HEAD para obtener tamaño
        const headResponse = await axios.head(downloadUrl, {
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
          }
        });

        const fileSize = parseInt(headResponse.headers['content-length'] || '0');
        const supportsRange = headResponse.headers['accept-ranges'] === 'bytes';

        // Paso 3: Descargar el archivo
        this.abortController = new AbortController();
        
        const response = await axios({
          method: 'GET',
          url: downloadUrl,
          responseType: 'stream',
          signal: this.abortController.signal,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Referer': url
          }
        });

        const writeStream = fs.createWriteStream(downloadPath);
        let downloadedSize = 0;
        let lastUpdate = Date.now();
        let lastDownloadedSize = 0;

        response.data.on('data', (chunk: Buffer) => {
          if (this.isAborted) {
            response.data.destroy();
            writeStream.close();
            reject(new Error('Download aborted'));
            return;
          }

          downloadedSize += chunk.length;

          const now = Date.now();
          if (now - lastUpdate >= 1000) {
            const timeDiff = (now - lastUpdate) / 1000;
            const sizeDiff = downloadedSize - lastDownloadedSize;
            const speed = sizeDiff / timeDiff;

            this.emitProgress({
              downloadedSize,
              totalSize: fileSize,
              speed
            });

            lastUpdate = now;
            lastDownloadedSize = downloadedSize;
          }
        });

        response.data.on('error', (error: Error) => {
          writeStream.close();
          this.emitError(error);
          reject(error);
        });

        response.data.on('end', () => {
          writeStream.close();
          this.emitComplete();
          resolve();
        });

        response.data.pipe(writeStream);

      } catch (error: any) {
        if (axios.isCancel(error)) {
          reject(new Error('Download cancelled'));
        } else if (error.response?.status === 403) {
          this.emitError(new Error('Límite de velocidad de 1fichier alcanzado. Espera unos minutos.'));
          reject(error);
        } else {
          this.emitError(error as Error);
          reject(error);
        }
      }
    });
  }

  abort(): void {
    super.abort();
    if (this.abortController) {
      this.abortController.abort();
    }
  }
}