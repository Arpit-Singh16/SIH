const Report = require('../models/Report');
const SymptomReport = require('../models/SymptomReport');

// Submit water report
exports.submitWaterReport = async (req, res) => {
  try {
    const userId = req.user._id;
    const { phValue, turbidity, nitrate_mg_per_l, waterSource, location } = req.body;

    const report = await Report.create({
      userId,
      phValue,
      turbidity,
      nitrate_mg_per_l,
      waterSource,
      location
    });

    res.status(201).json({
      success: true,
      data: report
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Get water reports
exports.getWaterReports = async (req, res) => {
  try {
    const userId = req.user._id;
    const limit = parseInt(req.query.limit) || 10;

    const reports = await Report.find({ userId })
      .sort({ createdAt: -1 })
      .limit(limit);

    res.status(200).json({
      success: true,
      data: reports
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Submit symptom report
exports.submitSymptomReport = async (req, res) => {
  try {
    const userId = req.user._id;
    const { personName, age, village, symptoms } = req.body;

    const report = await SymptomReport.create({
      userId,
      personName,
      age,
      village,
      symptoms
    });

    res.status(201).json({
      success: true,
      data: report
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Get symptom reports
exports.getSymptomReports = async (req, res) => {
  try {
    const userId = req.user._id;
    const limit = parseInt(req.query.limit) || 10;

    const reports = await SymptomReport.find({ userId })
      .sort({ createdAt: -1 })
      .limit(limit);

    res.status(200).json({
      success: true,
      data: reports
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};