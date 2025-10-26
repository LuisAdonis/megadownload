import { BaseDownloader } from './base.downloader';
import { MegaDownloader } from './mega.downloader';
import { FichierDownloader } from './fichier.downloader';
import { DownloadProvider } from '../../types';

export class DownloaderFactory {
  static createDownloader(url: string): { downloader: BaseDownloader; provider: DownloadProvider } {
    if (url.includes('mega.nz') || url.includes('mega.co.nz')) {
      return {
        downloader: new MegaDownloader(),
        provider: 'mega'
      };
    } else if (url.includes('1fichier.com')) {
      return {
        downloader: new FichierDownloader(),
        provider: '1fichier'
      };
    } else {
      throw new Error('Provider no soportado. Use Mega o 1fichier.');
    }
  }

  static detectProvider(url: string): DownloadProvider | null {
    if (url.includes('mega.nz') || url.includes('mega.co.nz')) {
      return 'mega';
    } else if (url.includes('1fichier.com')) {
      return '1fichier';
    }
    return null;
  }
}