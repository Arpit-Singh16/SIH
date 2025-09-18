const express = require('express');
const { predict, getPredictionHistory } = require('../controllers/predictionController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.use(protect);

router.post('/', predict);
router.get('/history', getPredictionHistory);

module.exports = router;