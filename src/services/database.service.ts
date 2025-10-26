import mongoose from 'mongoose';

export class DatabaseService {
  private static instance: DatabaseService;
  private isConnected: boolean = false;

  private constructor() {}

  static getInstance(): DatabaseService {
    if (!DatabaseService.instance) {
      DatabaseService.instance = new DatabaseService();
    }
    return DatabaseService.instance;
  }

  async connect(uri?: string): Promise<void> {
    if (this.isConnected) {
      console.log('⚠️  Ya conectado a MongoDB');
      return;
    }

    try {
      const MONGO_URI = uri || process.env.MONGO_URI || 'mongodb://localhost:27017/mega_downloads';
      await mongoose.connect(MONGO_URI);
      this.isConnected = true;
      console.log('✅ Conectado a MongoDB');
    } catch (error) {
      console.error('❌ Error conectando a MongoDB:', error);
      throw error;
    }
  }

  async disconnect(): Promise<void> {
    if (!this.isConnected) return;
    
    await mongoose.disconnect();
    this.isConnected = false;
    console.log('🔌 Desconectado de MongoDB');
  }

  getConnectionStatus(): boolean {
    return this.isConnected;
  }
}