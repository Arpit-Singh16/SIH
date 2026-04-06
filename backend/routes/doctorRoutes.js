
const express = require('express');
const { 
  getPredictionsByDistrict, 
  getPredictionsByVillage, 
  getDistrictSummary,
  getGraphDataByDistrict
} = require('../controllers/doctorController');


const router = express.Router();

// 🔹 Predictions by district
router.get('/predictions/district',getPredictionsByDistrict);

// 🔹 Predictions by village
router.get('/predictions/village',getPredictionsByVillage);
// router.get('/predictions/all',getAllPredictions);

// 🔹 District summary
router.get('/dashboard/summary',getDistrictSummary);

// 🔹 Graph data by district
router.get('/predictions/graph',getGraphDataByDistrict);

module.exports = router;