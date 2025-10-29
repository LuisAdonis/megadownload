import mongoose, { Schema, Document } from 'mongoose';

export type DownloadStatus = 'queued' | 'downloading' | 'paused' | 'completed' | 'failed' | 'quota_exceeded';

export interface IDownload extends Document {
  downloadId: string;
  url: string;
  fileName: string;
  fileSize: number;
  downloadedSize: number;
  status: DownloadStatus;
  progress: number;
  speed: number;
  timeRemaining: number;
  error: string | null;
  startTime: number | null;
  endTime: number | null;
  createdAt: number;
  updatedAt: number;
  provider: string
}

const downloadSchema = new Schema<IDownload>({
  downloadId: { type: String, required: true, unique: true },
  url: { type: String, required: true },
  fileName: { type: String, default: 'Cargando...' },
  fileSize: { type: Number, default: 0 },
  downloadedSize: { type: Number, default: 0 },
  status: { 
    type: String, 
    enum: ['queued', 'downloading', 'paused', 'completed', 'failed', 'quota_exceeded'],
    default: 'queued'
  },
  progress: { type: Number, default: 0 },
  speed: { type: Number, default: 0 },
  timeRemaining: { type: Number, default: 0 },
  error: { type: String, default: null },
  startTime: { type: Number, default: null },
  endTime: { type: Number, default: null },
  createdAt: { type: Number, default: Date.now },
  updatedAt: { type: Number, default: Date.now },
  provider: { type: String, enum: ['mega', '1fichier'], required: true }
});
downloadSchema.index({ status: 1, createdAt: -1 });
downloadSchema.index({ downloadId: 1 }, { unique: true });

export const Download = mongoose.model<IDownload>('Download', downloadSchema);
