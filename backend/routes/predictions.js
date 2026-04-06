const express = require("express");
const {
  predict,
  getLatestPrediction,
  getPredictionHistory,
  getHomepageData
} = require("../controllers/predictionController");

const { protect } = require("../middleware/auth");

const router = express.Router();

router.use(protect);

// ✅ /api/predictions
router.post("/", predict);

// ✅ /api/predictions/latest
router.get("/latest", getLatestPrediction);

router.get("/history",getPredictionHistory);
router.get("/homepage-data", getHomepageData);

module.exports = router;
