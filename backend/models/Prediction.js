const mongoose = require('mongoose');

const predictionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
      reportId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Report",
      required: true,
    },
  village: String,
  district: String,
  inputData: {
    rainfall_mm: Number,
    temperature_c: Number,
    phValue: Number,
    turbidity: Number,
    nitrate_mg_per_l: Number,
    waterSource: String,
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
