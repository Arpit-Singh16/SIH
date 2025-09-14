const express = require('express');
const router = express.Router();
const predictionController = require('../controllers/predictionController');
const { protect } = require('../middleware/auth'); // if you're using auth

// POST: Make a new prediction
router.post('/predict', protect, predictionController.predict);

// GET: Get prediction history
router.get('/predictions', protect, predictionController.getPredictionHistory);

// GET: Get homepage data
router.get('/homepage', protect, predictionController.getHomepageData);

module.exports = router;
