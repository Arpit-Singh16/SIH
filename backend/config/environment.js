require('dotenv').config();

const config = {
  development: {
    port: process.env.PORT || 5000,
    mongoUri: process.env.MONGODB_URI || 'mongodb://localhost:27017/waterborne_app',
    jwtSecret: process.env.JWT_SECRET || 'your_jwt_secret_here',
    mlServiceUrl: process.env.ML_SERVICE_URL || 'http://localhost:8000',
    nodeEnv: process.env.NODE_ENV || 'development'
  },
  production: {
    port: process.env.PORT,
    mongoUri: process.env.MONGODB_URI,
    jwtSecret: process.env.JWT_SECRET,
    mlServiceUrl: process.env.ML_SERVICE_URL,
    nodeEnv: process.env.NODE_ENV
  }
};

module.exports = config[process.env.NODE_ENV || 'development'];