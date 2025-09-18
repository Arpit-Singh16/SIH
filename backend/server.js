const app = require('./app');
const connectDB = require('./config/database');
const config = require('./config/environment');
const ModelLoader = require('./ml/modelLoader');

// Connect to database
connectDB();

// No need to load models since we're using FastAPI service
console.log('Using FastAPI ML service at:', config.mlServiceUrl);

// Test ML service connection (optional)
// ModelLoader.predictOutbreak({})
//   .then(result => {
//     console.log('ML service test successful:', result);
//   })
//   .catch(err => {
//     console.log('ML service test failed (this is normal if FastAPI is not running):', err.message);
//   });
// ModelLoader.predictCases({}).then(result=>{
//     console.log('ML service good:',result);
// })
// .catch(err=>{
//     console.log('error message:',err.message);
// })
// Start server
const server = app.listen(config.port, '0.0.0.0', () => {
  console.log(`Server running in ${process.env.NODE_ENV || 'development'} mode on port ${config.port}`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.log('UNHANDLED REJECTION! Shutting down...');
  console.log(err.name, err.message);
  server.close(() => {
    process.exit(1);
  });
});

// Handle SIGTERM
process.on('SIGTERM', () => {
  console.log('SIGTERM RECEIVED. Shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});