import { EventEmitter } from 'events';
import { DownloadProgress } from '../../types';

export abstract class BaseDownloader extends EventEmitter {
  protected isAborted: boolean = false;
  abstract getFileMetadata(url: string): Promise<FileMetadata>;
  abstract download(url: string, downloadPath: string): Promise<void>;

  protected emitProgress(progress: DownloadProgress): void {
    this.emit('progress', progress);
  }

  protected emitError(error: Error): void {
    this.emit('error', error);
  }

  protected emitComplete(): void {
    this.emit('complete');
  }

  abort(): void {
    this.isAborted = true;
  }

  reset(): void {
    this.isAborted = false;
  }
}
export interface FileMetadata {
  fileName: string;
  fileSize: number;
}