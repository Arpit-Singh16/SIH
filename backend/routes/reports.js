const express = require('express');
const { 
  submitWaterReport, 
  getWaterReports, 
  submitSymptomReport, 
  getSymptomReports 
} = require('../controllers/reportController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.use(protect);

router.post('/water', submitWaterReport);
router.get('/water', getWaterReports);
router.post('/symptoms', submitSymptomReport);
router.get('/symptoms', getSymptomReports);

module.exports = router;