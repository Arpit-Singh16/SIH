const mongoose = require('mongoose');

const symptomReportSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  personName: {
    type: String,
    required: true
  },
  age: {
    type: Number,
    required: true
  },
  village: {
    type: String,
    required: true
  },
  date: {
    type: Date,
    default: Date.now
  },
  symptoms: { 
    fever: { type: Boolean, default: false },
    vomiting: { type: Boolean, default: false },
    cough: { type: Boolean, default: false },
    cold: { type: Boolean, default: false },
    diarrhea: { type: Boolean, default: false },
    bodyAche: { type: Boolean, default: false },
    headache: { type: Boolean, default: false }
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('SymptomReport', symptomReportSchema);