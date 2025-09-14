// // ml/predictionService.js
// const ModelLoader = require('./modelLoader');
// const Prediction = require('../models/Prediction');

// class PredictionService {
//   constructor() {
//     this.modelLoader = ModelLoader;
//   }

//   async makePrediction(userId, inputData) {
//     try {
//       // Predict outbreak and cases
//       const outbreakPrediction = await this.modelLoader.predictOutbreak(inputData);
//       const casesPrediction = await this.modelLoader.predictCases(inputData);

//       // Save prediction to database
//       const predictionRecord = await Prediction.create({
//         userId,
//         inputData,
//         outbreakPrediction,
//         casesPrediction
//       });

//       // Return prediction summary
//       return {
//         outbreakChance: outbreakPrediction.probability,
//         predictedCases: casesPrediction.predictedCases,
//         predictionId: predictionRecord._id
//       };
//     } catch (error) {
//       console.error('Prediction service error:', error);
//       throw error;
//     }
//   }

//   async getHistoricalPredictions(userId, limit = 10) {
//     try {
//       const predictions = await Prediction.find({ userId })
//         .sort({ createdAt: -1 })
//         .limit(limit);

//       return predictions;
//     } catch (error) {
//       console.error('Error fetching historical predictions:', error);
//       throw error;
//     }
//   }
// }

// module.exports = new PredictionService();
const ModelLoader = require('./modelLoader');
const Prediction = require('../models/Prediction');
const Report = require('../models/Report');
const SymptomReport = require('../models/SymptomReport');

class PredictionService {
  async makePrediction(userId, inputData) {
    try {
      // ✅ If no inputData is provided, fetch from database
      if (!inputData || Object.keys(inputData).length === 0) {
        const latestWater = await Report.findOne({ userId }).sort({ createdAt: -1 });
        const latestSymptoms = await SymptomReport.findOne({ userId }).sort({ createdAt: -1 });

        if (!latestWater || !latestSymptoms) {
          throw new Error('No recent data found for prediction');
        }

        // Merge the needed fields into a single object
        inputData = {
          phValue: latestWater.phValue,
          turbidity: latestWater.turbidity,
          nitrate_mg_per_l: latestWater.nitrate_mg_per_l,
          waterSource: latestWater.waterSource,
          village: latestSymptoms.village,
          symptoms: latestSymptoms.symptoms
        };
      }

      // Send combined data to ML model
      const outbreakPrediction = await ModelLoader.predictOutbreak(inputData, userId);
      const casesPrediction = await ModelLoader.predictCases(inputData, userId);

      return {
        outbreakChance: outbreakPrediction.probability,
        predictedCases: casesPrediction.predictedCases
      };
    } catch (error) {
      console.error('Prediction service error:', error);
      throw error;
    }
  }
}

module.exports = new PredictionService();
