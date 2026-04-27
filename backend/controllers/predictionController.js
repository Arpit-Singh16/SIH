// const PredictionService = require("../ml/predictionService");
// const User = require("../models/User");
// const Prediction = require("../models/Prediction");

// // POST /api/predict
// exports.predict = async (req, res) => {
//   try {
//     const userId = req.user._id;

//     // ✅ safe + numeric conversion
//     const inputData = {
//       rainfall_mm: Number(req.body.rainfall_mm),
//       temperature_c: Number(req.body.temperature_c),
//       phValue: Number(req.body.phValue || req.body.ph),
//       turbidity: Number(req.body.turbidity),
//       nitrate_mg_per_l: Number(req.body.nitrate_mg_per_l),
//       waterSource: req.body.waterSource || req.body.water_source,
//       district: req.body.district,
//     };

//     console.log("Input data for prediction:", inputData);

//     // ✅ Run prediction
//     const prediction = await PredictionService.makePrediction(userId, inputData);
//     console.log("Prediction result:", prediction);

//     // ✅ Save prediction to DB
//     const saved = await Prediction.create({
//       userId: userId,
//       inputData: inputData,
//       outbreakPrediction: {
//         probability: prediction.outbreakChance,
//         prediction: prediction.outbreakChance > 0.5,
//       },
//       casesPrediction: {
//         predictedCases: prediction.predictedCases,
//       },
//       timestamp: new Date(),
//     });

//     return res.status(200).json({
//       success: true,
//       data: saved,
//     });
//   } catch (error) {
//     return res.status(500).json({
//       success: false,
//       message: error.message,
//     });
//   }
// };

// // ✅ GET /api/predictions/latest
// exports.getLatestPrediction = async (req, res) => {
//   try {
//     const userId = req.user._id;

//     // ✅ latest prediction only (skip removed)
//     const latest = await Prediction.findOne({ userId: userId }).sort({
//       createdAt: -1,
//     });

//     if (!latest) {
//       return res.status(404).json({
//         success: false,
//         message: "No predictions found for this user",
//       });
//     }

//     return res.status(200).json({
//       success: true,
//       data: latest,
//     });
//   } catch (error) {
//     return res.status(500).json({
//       success: false,
//       message: error.message,
//     });
//   }
// };

// // ✅ GET /api/predictions/homepage
// exports.getHomepageData = async (req, res) => {
//   try {
//     const userId = req.user._id;

//     const user = await User.findById(userId);

//     // ✅ Get latest prediction from DB
//     const lastPrediction = await Prediction.findOne({ userId: userId }).sort({
//       createdAt: -1,
//     });

//     // ✅ inputData fallback
//     const inputData = lastPrediction?.inputData
//       ? lastPrediction.inputData
//       : {
//         rainfall_mm: 45,
//         temperature_c: 35,
//         phValue: 7.0,
//         turbidity: 18,
//         nitrate_mg_per_l: 12.5,
//         waterSource: "Well",
//         district: user?.district || "Default District",
//         humidity_pct: 60, // ✅ default
//       };

//     const homepageData = {
//       alert:
//         "⚠️ Alert: Increase in water-borne diseases reported in your area. Please check households for safe drinking water and sanitation.",
//       outbreakChance: lastPrediction?.outbreakPrediction?.probability || 0,

//       waterQuality: {
//         score: 80, // Default or calculated
//         ph: inputData.phValue,
//         turbidity: inputData.turbidity,
//         bacteria: 150, // Default or calculated
//       },

//       weather: {
//         condition: "☀️ Sunny",
//         temperature: inputData.temperature_c,
//         humidity: inputData.humidity_pct || 60,
//         rain: inputData.rainfall_mm,
//         wind: 12,
//       },

//       precautions: [
//         "✅ Drink boiled/filtered water",
//         "✅ Store water in clean covered containers",
//         "✅ Wash hands with soap regularly",
//         "✅ Wash fruits & vegetables before eating",
//         "✅ Avoid unhygienic street food",
//         "✅ Use toilets, avoid open defecation",
//         "✅ Clean water tanks regularly",
//         "✅ Prevent stagnant water near homes",
//       ],
//     };

//     return res.status(200).json({
//       success: true,
//       data: homepageData,
//     });
//   } catch (error) {
//     return res.status(500).json({
//       success: false,
//       message: error.message,
//     });
//   }
// };


const PredictionService = require("../ml/predictionService");
const User = require("../models/User");
const Prediction = require("../models/Prediction");

// ✅ helper to avoid NaN
const toNumber = (value, fallback = 0) => {
  const num = Number(value);
  return Number.isFinite(num) ? num : fallback;
};

// ✅ POST /api/predictions   (manual prediction API)
exports.predict = async (req, res) => {
  try {
    const userId = req.user._id;

    // ✅ Safe numeric conversion (avoid NaN)
    const inputData = {
      rainfall_mm: toNumber(req.body.rainfall_mm, 0),
      temperature_c: toNumber(req.body.temperature_c, 30),
      phValue: toNumber(req.body.phValue || req.body.ph, 7),
      turbidity: toNumber(req.body.turbidity, 0),
      nitrate_mg_per_l: toNumber(req.body.nitrate_mg_per_l, 0),
      waterSource: req.body.waterSource || req.body.water_source || "Unknown",
      district: req.body.district || "Unknown District",
    };

    console.log("Input data for prediction:", inputData);

    // ✅ Run prediction
    const result = await PredictionService.makePrediction(userId, inputData);

    // ✅ Save ONLY ONCE
    const saved = await Prediction.create({
      userId,
      inputData,
      outbreakPrediction: result.outbreakPrediction, //  comes from ML loader
      casesPrediction: result.casesPrediction,
      timestamp: new Date(),
    });

    return res.status(200).json({
      success: true,
      data: saved,
    });
  } catch (error) {
    console.error("predict controller error:", error.message);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ✅ GET /api/predictions/latest
exports.getLatestPrediction = async (req, res) => {
  try {
    const userId = req.user._id;

    const latest = await Prediction.findOne({ userId }).sort({ createdAt: -1 });

    if (!latest) {
      return res.status(404).json({
        success: false,
        message: "No predictions found for this user",
      });
    }

    return res.status(200).json({
      success: true,
      data: latest,
    });
  } catch (error) {
    console.error("getLatestPrediction error:", error.message);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ✅ GET /api/predictions/homepage
exports.getHomepageData = async (req, res) => {
  try {
    const userId = req.user._id;

    const user = await User.findById(userId);

    // ✅ Latest prediction (with report populated if reportId exists)
    const lastPrediction = await Prediction.findOne({ userId })
      .sort({ createdAt: -1 })
      .populate("reportId"); // ✅ works only if you add reportId in schema

    if (!lastPrediction) {
      return res.status(200).json({
        success: true,
        data: {
          alert: "Submit your water report to get prediction results.",
          outbreakChance: 0,
          latestReport: null,
          latestPrediction: null,
        },
      });
    }

    const inputData = lastPrediction.inputData || {
      rainfall_mm: 0,
      temperature_c: 30,
      phValue: 7,
      turbidity: 0,
      nitrate_mg_per_l: 0,
      waterSource: "Unknown",
      district: user?.district || "Unknown District",
      humidity_pct: 60,
    };

    const homepageData = {
      alert:
        "⚠️ Alert: Increase in water-borne diseases reported in your area. Please check households for safe drinking water and sanitation.",

      // ✅ outbreak chance in percentage
      outbreakChance: lastPrediction?.outbreakPrediction?.probability || 0,

      // ✅ include full objects so frontend can show exact info
      latestReport: lastPrediction.reportId || null,
      latestPrediction: lastPrediction,

      waterQuality: {
        score: 80,
        ph: inputData.phValue,
        turbidity: inputData.turbidity,
        nitrate: inputData.nitrate_mg_per_l,
      },

      weather: {
        condition: "☀️ Sunny",
        temperature: inputData.temperature_c,
        humidity: inputData.humidity_pct || 60,
        rain: inputData.rainfall_mm,
        wind: 12,
      },

      precautions: [
        "✅ Drink boiled/filtered water",
        "✅ Store water in clean covered containers",
        "✅ Wash hands with soap regularly",
        "✅ Wash fruits & vegetables before eating",
        "✅ Avoid unhygienic street food",
        "✅ Use toilets, avoid open defecation",
        "✅ Clean water tanks regularly",
        "✅ Prevent stagnant water near homes",
      ],
    };

    return res.status(200).json({
      success: true,
      data: homepageData,
    });
  } catch (error) {
    console.error("getHomepageData error:", error.message);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ✅ GET /api/predictions/history
exports.getPredictionHistory = async (req, res) => {
  try {
    const userId = req.user._id;

    const history = await Prediction.find({ userId })
      .sort({ createdAt: -1 })
      .populate("reportId"); // ✅ report linked

    return res.status(200).json({
      success: true,
      data: history,
    });
  } catch (error) {
    console.error("getPredictionHistory error:", error.message);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

