const geminiService = require('../services/gemini.service');

class AssessmentController {
    async generate(req, res, next) {
        try {
            const { symptoms, age, gender, description, language } = req.body;

            // Basic Validation
            if (!age || !gender || !language) {
                return res.status(400).json({
                    success: false,
                    message: 'Missing required fields: age, gender, or language'
                });
            }

            // Call Service with Timeout (15s) to guarantee response
            const serviceCall = geminiService.generateAssessment({
                symptoms: symptoms || [],
                age,
                gender,
                description,
                language
            });

            const timeoutPromise = new Promise((resolve) => {
                setTimeout(() => {
                    resolve({
                        summary: "Service timed out. Please try again.",
                        riskLevel: "Unknown",
                        error: true,
                        timedOut: true
                    });
                }, 15000);
            });

            const result = await Promise.race([serviceCall, timeoutPromise]);

            // Send Response
            res.json({
                success: true,
                data: result
            });

        } catch (error) {
            next(error);
        }
    }
}

module.exports = new AssessmentController();
