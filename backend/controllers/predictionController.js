const PredictionService = require('../ml/predictionService');
const User = require('../models/User');
const Prediction = require('../models/Prediction'); // <-- add your Prediction model

// POST /api/predict
// exports.predict = async (req, res) => {
//   try {
//     const userId = req.user._id;
//     const inputData = req.body;

//     // Run prediction
//     const prediction = await PredictionService.makePrediction(userId, inputData);

//     // Save prediction result to DB
//     const saved = await Prediction.create({
//       user: userId,
//       input: inputData,
//       result: prediction,
//       createdAt: new Date()
//     });

//     res.status(200).json({
//       success: true,
//       data: saved
//     });
//   } catch (error) {
//     res.status(500).json({
//       success: false,
//       message: error.message
//     });
//   }
// };
exports.predict = async (req, res) => {
  try {
    const userId = req.user._id;

    // data from frontend body
    const inputData = {
      rainfall_mm: req.body.rainfall_mm,
      temperature_c: req.body.temperature_c,
      ph: req.body.ph,
      turbidity: req.body.turbidity,
      nitrate_mg_per_l: req.body.nitrate_mg_per_l,
      water_source: req.body.water_source,
      district: req.body.district
    };

    const prediction = await PredictionService.makePrediction(userId, inputData);

    const saved =   await Prediction.create({
      user: userId,
      input: inputData,
      result: prediction,
      createdAt: new Date()
    });

    res.status(200).json({
      success: true,
      prediction
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};


// GET /api/predictions?limit=10
exports.getPredictionHistory = async (req, res) => {
  try {
    const userId = req.user._id;
    const limit = parseInt(req.query.limit) || 10;

    const predictions = await Prediction.find({ user: userId })
      .sort({ createdAt: -1 })
      .limit(limit);

    res.status(200).json({
      success: true,
      data: predictions
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// GET /api/homepage
exports.getHomepageData = async (req, res) => {
  try {
    const userId = req.user._id;

    const user = await User.findById(userId);

    // Get the most recent prediction input from DB
    const lastPrediction = await Prediction.findOne({ user: userId })
      .sort({ createdAt: -1 });

    const inputData = lastPrediction ? lastPrediction.input : {
      
      week: new Date().getWeek?.() || 36,
     rainfall_mm: 45,
  temperature_c: 35,
  ph: 7.0,
  turbidity: 18,
  nitrate_mg_per_l: 12.5,
  water_source: "Well",
  district: user.district || "Default District"
    };

    const prediction = await PredictionService.makePrediction(userId, inputData);

    const homepageData = {
      alert: "⚠️ Alert: Increase in water-borne diseases reported in your area. Please check households for safe drinking water and sanitation.",
      outbreakChance: prediction.outbreakChance,
      waterQuality: {
        score: prediction.qualityScore || 80,
        ph: inputData.ph,
        turbidity: inputData.turbidity,
        bacteria: prediction.bacteriaCount || 150
      },
      weather: {
        condition: "☀️ Sunny",
        temperature: inputData.temperature_c,
        humidity: inputData.humidity_pct,
        rain: inputData.rainfall_mm,
        wind: 12
      },
      precautions: [
        "✅ Drink boiled/filtered water",
        "✅ Store water in clean covered containers",
        "✅ Wash hands with soap regularly",
        "✅ Wash fruits & vegetables before eating",
        "✅ Avoid unhygienic street food",
        "✅ Use toilets, avoid open defecation",
        "✅ Clean water tanks regularly",
        "✅ Prevent stagnant water near homes"
      ]
    };

    res.status(200).json({
      success: true,
      data: homepageData
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
