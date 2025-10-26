
export const config = {
  port: process.env.PORT || 3000,
  mongoUri: process.env.MONGO_URI || 'mongodb://localhost:27017/mega_downloads',
  downloadPath: process.env.DOWNLOAD_PATH || './downloads',
  maxConcurrent: Number(process.env.MAX_CONCURRENT) || 3,
};