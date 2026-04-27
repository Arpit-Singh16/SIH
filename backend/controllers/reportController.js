// const Report = require('../models/Report');
// const SymptomReport = require('../models/SymptomReport');

// // Submit water report
// exports.submitWaterReport = async (req, res) => {
//   try {
//     const userId = req.user._id;
//     const { phValue, turbidity, nitrate_mg_per_l, waterSource, location } = req.body;

//     const report = await Report.create({
//       userId,
//       phValue,
//       turbidity,
//       nitrate_mg_per_l,
//       waterSource,
//       location
//     });

//     res.status(201).json({
//       success: true,
//       data: report
//     });
//   } catch (error) {
//     res.status(500).json({
//       success: false,
//       message: error.message
//     });
//   }
// };

// // Get water reports
// exports.getWaterReports = async (req, res) => {
//   try {
//     const userId = req.user._id;
//     const limit = parseInt(req.query.limit) || 10;

//     const reports = await Report.find({ userId })
//       .sort({ createdAt: -1 })
//       .limit(limit);

//     res.status(200).json({
//       success: true,
//       data: reports
//     });
//   } catch (error) {
//     res.status(500).json({
//       success: false,
//       message: error.message
//     });
//   }
// };

// // Submit symptom report
// exports.submitSymptomReport = async (req, res) => {
//   try {
//     const userId = req.user._id;
//     const { personName, age, village, symptoms } = req.body;

//     const report = await SymptomReport.create({
//       userId,
//       personName,
//       age,
//       village,
//       symptoms
//     });

//     res.status(201).json({
//       success: true,
//       data: report
//     });
//   } catch (error) {
//     res.status(500).json({
//       success: false,
//       message: error.message
//     });
//   }
// };

// // Get symptom reports
// exports.getSymptomReports = async (req, res) => {
//   try {
//     const userId = req.user._id;
//     const limit = parseInt(req.query.limit) || 10;

//     const reports = await SymptomReport.find({ userId })
//       .sort({ createdAt: -1 })
//       .limit(limit);

//     res.status(200).json({
//       success: true,
//       data: reports
//     });
//   } catch (error) {
//     res.status(500).json({
//       success: false,
//       message: error.message
//     });
//   }
// };


const Report = require("../models/Report");
const SymptomReport = require("../models/SymptomReport");
const Prediction = require("../models/Prediction");
const PredictionService = require("../ml/predictionService");

// ✅ helper to avoid NaN
const toNumber = (value, fallback = 0) => {
  const num = Number(value);
  return Number.isFinite(num) ? num : fallback;
};

// ✅ Submit water report + generate prediction (AUTO)
exports.submitWaterReport = async (req, res) => {
  try {
    const userId = req.user._id;
    const { phValue, turbidity, nitrate_mg_per_l, waterSource, location } = req.body;

    // ✅ 1) Create water report
    const report = await Report.create({
      userId,
      phValue: toNumber(phValue, 7),
      turbidity: toNumber(turbidity, 0),
      nitrate_mg_per_l: toNumber(nitrate_mg_per_l, 0),
      waterSource,
      location,
    });

    // ✅ 2) Build ML input data from THIS report
    // rainfall & temperature should come from external source, for now safe default
    const inputData = {
      rainfall_mm: toNumber(req.body.rainfall_mm, 0),
      temperature_c: toNumber(req.body.temperature_c, 30),

      phValue: report.phValue,
      turbidity: report.turbidity,
      nitrate_mg_per_l: report.nitrate_mg_per_l,
      waterSource: report.waterSource,

      district: report.location?.district || "Unknown District",
    };

    // ✅ 3) Predict using ML service
    const result = await PredictionService.makePrediction(userId, inputData);

    // ✅ 4) Save Prediction linked to this report
    const prediction = await Prediction.create({
      userId,
      reportId: report._id, 
      inputData,
      outbreakPrediction: result.outbreakPrediction,
      casesPrediction: result.casesPrediction,
      timestamp: new Date(),
    });

    
    return res.status(201).json({
      success: true,
      message: "Water report submitted and prediction generated",
      data: {
        report,
        prediction,
      },
    });
  } catch (error) {
    console.error("submitWaterReport error:", error.message);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ✅ Get water reports
exports.getWaterReports = async (req, res) => {
  try {
    const userId = req.user._id;
    const limit = parseInt(req.query.limit) || 10;

    const reports = await Report.find({ userId })
      .sort({ createdAt: -1 })
      .limit(limit);

    return res.status(200).json({
      success: true,
      data: reports,
    });
  } catch (error) {
    console.error("getWaterReports error:", error.message);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ✅ Submit symptom report (no prediction here)
exports.submitSymptomReport = async (req, res) => {
  try {
    const userId = req.user._id;
    const { personName, age, village, symptoms, district } = req.body;

    const report = await SymptomReport.create({
      userId,
      personName,
      age: toNumber(age, 0),
      village,
      district, // ✅ add if you want district in symptoms model
      symptoms,
    });

    return res.status(201).json({
      success: true,
      data: report,
    });
  } catch (error) {
    console.error("submitSymptomReport error:", error.message);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ✅ Get symptom reports
exports.getSymptomReports = async (req, res) => {
  try {
    const userId = req.user._id;
    const limit = parseInt(req.query.limit) || 10;

    const reports = await SymptomReport.find({ userId })
      .sort({ createdAt: -1 })
      .limit(limit);

    return res.status(200).json({
      success: true,
      data: reports,
    });
  } catch (error) {
    console.error("getSymptomReports error:", error.message);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
