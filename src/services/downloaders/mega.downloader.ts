import { File } from 'megajs';
import * as fs from 'fs';
import { BaseDownloader,FileMetadata  } from './base.downloader';

export class MegaDownloader extends BaseDownloader {
  private downloadStream: any = null;
  private writeStream: any = null;
 async getFileMetadata(url: string): Promise<FileMetadata> {
    return new Promise((resolve, reject) => {
      try {
        const file = File.fromURL(url);

        file.loadAttributes((error) => {
          if (error) {
            reject(error);
            return;
          }

          resolve({
            fileName: file.name || 'archivo_sin_nombre',
            fileSize: file.size || 0
          });
        });
      } catch (error) {
        reject(error);
      }
    });
  }
  async download(url: string, downloadPath: string): Promise<void> {
    return new Promise(async (resolve, reject) => {
      try {
        const file = File.fromURL(url);

        await new Promise<void>((res, rej) => {
          file.loadAttributes((error) => {
            if (error) {
              rej(error);
              return;
            }
            res();
          });
        });

        const fileSize = file.size || 0;
        this.writeStream = fs.createWriteStream(downloadPath);
        this.downloadStream = file.downloadBuffer;

        let downloadedSize = 0;
        let lastUpdate = Date.now();
        let lastDownloadedSize = 0;

        this.downloadStream.on('data', (chunk: Buffer) => {
          if (this.isAborted) {
            this.downloadStream.destroy();
            this.writeStream.close();
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

        this.downloadStream.on('error', (error: Error) => {
          this.writeStream.close();
          this.emitError(error);
          reject(error);
        });

        this.downloadStream.on('end', () => {
          this.writeStream.close();
          this.emitComplete();
          resolve();
        });

        this.downloadStream.pipe(this.writeStream);

      } catch (error) {
        this.emitError(error as Error);
        reject(error);
      }
    });
  }

  abort(): void {
    super.abort();
    if (this.downloadStream) {
      this.downloadStream.destroy();
    }
    if (this.writeStream) {
      this.writeStream.close();
    }
  }
}