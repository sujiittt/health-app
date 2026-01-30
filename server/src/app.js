const express = require('express');
const cors = require('cors');
const assessmentRoutes = require('./routes/assessment.routes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/assessment', assessmentRoutes);

// Health Check
app.get('/', (req, res) => {
    res.json({ message: 'Swasthya Sahayak Backend is Running!' });
});

// Error Handler
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        success: false,
        message: 'Internal Server Error',
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

module.exports = app;
