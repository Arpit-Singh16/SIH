const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  phValue: {
    type: Number,
    required: true
  },
  turbidity: {
    type: Number,
    required: true
  },
  nitrate_mg_per_l: {
    type: Number,
    required: true
  },
  waterSource: {
    type: String,
    required: true
  },
  location: {
    village: String,
    district: String,
    state: String
  },
  date: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Report', reportSchema);