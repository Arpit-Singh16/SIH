
// const ModelLoader = require('./modelLoader');
// const Prediction = require('../models/Prediction');
// const Report = require('../models/Report');
// const SymptomReport = require('../models/SymptomReport');

// class PredictionService {
//   async makePrediction(userId, inputData) {
//     try {
//       // ✅ If no inputData is provided, fetch from database
//       if (!inputData || Object.keys(inputData).length === 0) {
//         const latestWater = await Report.findOne({ userId }).sort({ createdAt: -1 });
//         const latestSymptoms = await SymptomReport.findOne({ userId }).sort({ createdAt: -1 });

//         if (!latestWater || !latestSymptoms) {
//           throw new Error('No recent data found for prediction');
//         }

//         // Merge the needed fields into a single object
//         inputData = {
//           phValue: latestWater.phValue,
//           turbidity: latestWater.turbidity,
//           nitrate_mg_per_l: latestWater.nitrate_mg_per_l,
//           waterSource: latestWater.waterSource,
//           village: latestSymptoms.village,
//           symptoms: latestSymptoms.symptoms
//         };
//       }

//       // Send combined data to ML model
//       const outbreakPrediction = await ModelLoader.predictOutbreak(inputData, userId);
//       const casesPrediction = await ModelLoader.predictCases(inputData, userId);

//       return {
//         outbreakChance: outbreakPrediction.probability,
//         predictedCases: casesPrediction.predictedCases
//       };
//     } catch (error) {
//       console.error('Prediction service error:', error);
//       throw error;
//     }
//   }
// }

// module.exports = new PredictionService();


const ModelLoader = require("./modelLoader");
const Report = require("../models/Report");
const SymptomReport = require("../models/SymptomReport");

class PredictionService {
  async makePrediction(userId, inputData) {
    try {
      // ✅ If no inputData is provided, fetch from database
      if (!inputData || Object.keys(inputData).length === 0) {
        const latestWater = await Report.findOne({ userId }).sort({ createdAt: -1 });
        const latestSymptoms = await SymptomReport.findOne({ userId }).sort({ createdAt: -1 });

        if (!latestWater) {
          throw new Error("No recent water report found for prediction");
        }

        // ✅ district fallback
        const district =
          latestWater.location?.district || latestSymptoms?.district || "Unknown District";

        // ✅ ML required fields must exist
        inputData = {
          rainfall_mm: 0,
          temperature_c: 30,
          phValue: latestWater.phValue,
          turbidity: latestWater.turbidity,
          nitrate_mg_per_l: latestWater.nitrate_mg_per_l,
          waterSource: latestWater.waterSource,
          district,
        };
      }

      // ✅ Send to ML model (NO DB saving here)
      const outbreakPrediction = await ModelLoader.predictOutbreak(inputData);
      const casesPrediction = await ModelLoader.predictCases(inputData);

      // ✅ Return full objects so controller can save properly
      return {
        outbreakPrediction,
        casesPrediction,
      };
    } catch (error) {
      console.error("Prediction service error:", error.message);
      throw error;
    }
  }
}

module.exports = new PredictionService();

