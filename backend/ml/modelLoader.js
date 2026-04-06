// ml/modelLoader.js
const axios = require('axios');
const config = require('../config/environment');
const Prediction = require('../models/Prediction');


const ML_URL = config.mlServiceUrl || "http://localhost:8000";

class ModelLoader {
  constructor() {
    this.mlServiceUrl = ML_URL;
  }

  prepareFeatures(data) {
    // Use dynamic data if provided, otherwise defaults
    return {
      rainfall_mm: data.rainfall_mm,
      temperature_c: data.temperature_c,
      ph: data.phValue || data.ph,
      turbidity: data.turbidity,
      nitrate_mg_per_l: data.nitrate_mg_per_l,
      water_source: data.waterSource || data.water_source,
      district: data.district
    };
  }
  async predictOutbreak(data, userId = null) {
    try {
      const dbInputData = {
        rainfall_mm: data.rainfall_mm,
        temperature_c: data.temperature_c,
        phValue: data.phValue || data.ph,
        turbidity: data.turbidity,
        nitrate_mg_per_l: data.nitrate_mg_per_l,
        waterSource: data.waterSource || data.water_source,
        district: data.district
      };

      const payload = this.prepareFeatures(dbInputData);
      console.log("Sending outbreak payload:", payload);

      const response = await axios.post(
        `${ML_URL}/predict_classification`,
        payload,
        { headers: { "Content-Type": "application/json" } }
      );

      const outbreakPrediction = {
        probability: response.data.outbreak_probability_percentage || 0,
        prediction: response.data.outbreak_prediction ?? false
      };

      // Save to MongoDB if userId is provided
      if (userId) {
        await Prediction.create({
          userId,
          inputData: dbInputData,
          outbreakPrediction
        });
      }

      return outbreakPrediction;
    } catch (error) {
      console.error('ML Service error (outbreak):', error.response?.data || error.message);
      return { probability: 70.0, prediction: true };
    }
  }

  async predictCases(data, userId = null) {
    try {
      const dbInputData = {
        rainfall_mm: data.rainfall_mm,
        temperature_c: data.temperature_c,
        phValue: data.phValue || data.ph,
        turbidity: data.turbidity,
        nitrate_mg_per_l: data.nitrate_mg_per_l,
        waterSource: data.waterSource || data.water_source,
        district: data.district
      };

      const payload = this.prepareFeatures(dbInputData);
      console.log("Sending regression payload:", payload);

      const response = await axios.post(
        `${ML_URL}/predict_regression`,
        payload,
        { headers: { "Content-Type": "application/json" } }
      );

      const casesPrediction = {
        predictedCases: response.data.confirmed_waterborne_cases ?? 15
      };

      // Save to MongoDB if userId is provided
      if (userId) {
        await Prediction.create({
          userId,
          inputData: dbInputData,
          casesPrediction
        });
      }

      return casesPrediction;
    } catch (error) {
      console.error('ML Service error (cases):', error.response?.data || error.message);
      return { predictedCases: 15 };
    }
  }
}

module.exports = new ModelLoader();
