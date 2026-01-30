const express = require('express');
const router = express.Router();
const assessmentController = require('../controllers/assessment.controller');

// POST /api/assessment/generate
router.post('/generate', assessmentController.generate);

module.exports = router;
