const mongoose = require('mongoose');

const predictionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  inputData: {
    rainfall_mm: Number,
    temperature_c: Number,
    ph: Number,
    turbidity: Number,
    nitrate_mg_per_l: Number,
    water_source: String,
    district: String
  },
  outbreakPrediction: {
    probability: Number,
    prediction: Boolean
  },
  casesPrediction: {
    predictedCases: Number
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Prediction', predictionSchema);
