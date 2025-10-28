
export const config = {
  port: process.env.PORT || 3000,
  mongoUri: process.env.MONGO_URI || 'mongodb://root:facturacion@192.168.123.40:27017/megadownload?authSource=admin',
  downloadPath: process.env.DOWNLOAD_PATH || './downloads',
  maxConcurrent: Number(process.env.MAX_CONCURRENT) || 3,
};