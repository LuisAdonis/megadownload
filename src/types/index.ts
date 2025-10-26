export type DownloadProvider = 'mega' | '1fichier';

export interface DownloadInfo {
  id: string;
  url: string;
  fileName: string;
  fileSize: number;
  downloadedSize: number;
  status: 'queued' | 'downloading' | 'paused' | 'completed' | 'failed' | 'quota_exceeded';
  progress: number;
  speed: number;
  timeRemaining?: number;
  error?: string;
  startTime?: number;
  endTime?: number;
  createdAt: number;
  provider: DownloadProvider;
}

export interface DownloadOptions {
  downloadPath?: string;
  priority?: 'high' | 'medium' | 'low';
}

export interface ManagerOptions {
  maxConcurrent?: number;
  downloadPath?: string;
}

export interface DownloadStats {
  total: number;
  queued: number;
  downloading: number;
  paused: number;
  completed: number;
  failed: number;
  quota_exceeded: number;
  totalSpeed: number;
}

export interface IDownloader {
  download(url: string, downloadPath: string): Promise<void>;
  pause?(): void;
  resume?(): void;
  onProgress?(callback: (progress: DownloadProgress) => void): void;
}

export interface DownloadProgress {
  downloadedSize: number;
  totalSize: number;
  speed: number;
}