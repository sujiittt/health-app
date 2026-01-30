const { GoogleGenerativeAI, HarmCategory, HarmBlockThreshold } = require('@google/generative-ai');

class GeminiService {
    constructor() {
        const apiKey = process.env.GEMINI_API_KEY;
        if (!apiKey) {
            console.error('Warning: GEMINI_API_KEY is not set in .env');
        }

        this.genAI = new GoogleGenerativeAI(apiKey);
        this.model = this.genAI.getGenerativeModel({
            model: "gemini-2.5-flash",
            generationConfig: {
                temperature: 0.7,
                maxOutputTokens: 1024,
            },
            safetySettings: [
                { category: HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
                { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
                { category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
                { category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
            ]
        });
    }

    async generateAssessment(data) {
        const { symptoms, age, gender, description, language } = data;

        // Map language
        const languageMap = {
            'en': 'English',
            'hi': 'Hindi (हिंदी)',
            'mr': 'Marathi (मराठी)',
            'English': 'English',
            'Hindi': 'Hindi (हिंदी)',
            'Marathi': 'Marathi (मराठी)'
        };

        const targetLanguage = languageMap[language] || languageMap['en'];
        const symptomsText = Array.isArray(symptoms) ? symptoms.join(', ') : symptoms;

        const prompt = `
You are a culturally sensitive health advisor for rural India. Generate personalized health recommendations based on:

Patient Details:
- Gender: ${gender}
- Age: ${age}
- Main Symptoms: ${symptomsText}
- Description: "${description || 'None provided'}"
- Language: ${targetLanguage}

Provide specific guidance in the following JSON format structure (do not use markdown code blocks, just raw JSON):
{
  "summary": "A brief summary (2-3 sentences) explaining the condition in simple terms.",
  "recommendations": "List of 5-7 practical, actionable recommendations. Use bullet points or numbered list in the string.",
  "culturalTips": "Cultural considerations (home remedies, dietary advice common in Indian households).",
  "warningSigns": "When to seek immediate medical attention or call 108.",
  "riskLevel": "Low Risk | Medium Risk | High Risk"
}

IMPORTANT:
- Write ENTIRELY in ${targetLanguage}.
- Use simple, clear language that rural populations can understand.
- Be empathetic and reassuring.
- Do NOT provide a medical diagnosis. Use phrases like "It appears to be...", "Possible causes include...".
- For "riskLevel", estimate based on symptoms (e.g., chest pain = High Risk, mild cold = Low Risk).
`;

        try {
            const result = await this.model.generateContent(prompt);
            const response = await result.response;
            const text = response.text();
            // 1. Clean Markdown Code Blocks
            let cleanedText = text.replace(/```json/gi, '').replace(/```/g, '').trim();

            // 2. Try Standard JSON Parse from Cleaner text
            const jsonMatch = cleanedText.match(/\{[\s\S]*\}/);

            let parsedData = null;

            if (jsonMatch) {
                try {
                    parsedData = JSON.parse(jsonMatch[0]);
                } catch (e) {
                    console.error('Failed to parse (even cleaned) JSON, using manual extractor:', e);
                }
            }

            // 3. Manual Extraction (if parse failed)
            if (!parsedData) {
                const extractField = (fieldName) => {
                    const patterns = [
                        new RegExp(`"${fieldName}"\\s*:\\s*"([^"]*)"`, 'i'),
                        new RegExp(`"${fieldName}"\\s*:\\s*'([^']*)'`, 'i'),
                        new RegExp(`'${fieldName}'\\s*:\\s*"([^"]*)"`, 'i'),
                        new RegExp(`'${fieldName}'\\s*:\\s*'([^']*)'`, 'i'),
                        new RegExp(`${fieldName}\\s*:\\s*"([^"]*)"`, 'i')
                    ];
                    for (const p of patterns) {
                        const m = text.match(p); // Use original text for regex matching to be safe
                        if (m && m[1]) return m[1];
                    }
                    return "";
                };

                const summary = extractField('summary');
                const recommendations = extractField('recommendations');

                // If regex found something, populate parsedData
                if (summary.length > 5 || recommendations.length > 5) {
                    parsedData = {
                        summary,
                        recommendations,
                        warningSigns: extractField('warningSigns'),
                        culturalTips: extractField('culturalTips'),
                        riskLevel: extractField('riskLevel')
                    };
                }
            }

            // 4. Force Normalization (The "Layer")
            if (!parsedData) {
                // FAILURE SCENARIO: JSON parse failed, Regex extraction failed.
                // We likely have a malformed JSON string like: { "summary": "Good...
                // We must STRIP all JSON syntax to save the user experience.

                let safeText = cleanedText;

                // A. Strip wrapping braces
                safeText = safeText.replace(/^[\s\n]*\{/, '').replace(/\}[\s\n]*$/, '');

                // B. Remove common keys if they appear at start of lines (e.g. "summary":)
                const keysToRemove = ['summary', 'recommendations', 'culturalTips', 'warningSigns', 'riskLevel', 'data'];
                keysToRemove.forEach(key => {
                    // Regex removes "key": or 'key': or key:
                    safeText = safeText.replace(new RegExp(`['"]?${key}['"]?\\s*:\\s*`, 'gi'), '');
                });

                // C. Cleanup stray quotes and commas at end of lines
                safeText = safeText.replace(/",\s*$/gm, '\n') // Quote-comma at EOL -> Newline
                    .replace(/',\s*$/gm, '\n')
                    .replace(/"\s*$/gm, '')
                    .replace(/^"/gm, '');      // Quote at start of line

                // D. Ensure we don't return an empty string
                if (safeText.trim().length < 5) {
                    safeText = "Guidance generated, but format was unclear. Please consult a doctor for advice.";
                }

                parsedData = {
                    summary: safeText.trim(),
                    recommendations: [],
                    culturalTips: "",
                    warningSigns: "",
                    riskLevel: "Medium Risk",
                    rawText: safeText.trim(),
                    structuredData: false
                };
            }

            // Final Polish: Ensure types are correct AND Sanitized
            const sanitizeString = (str) => {
                if (typeof str !== 'string') return "";
                // If it STILL looks like JSON code (starts with quotes or braces), nukem.
                if (str.trim().startsWith('{') || str.trim().startsWith('[') || str.trim().startsWith('"')) {
                    return str.replace(/[{}"\[\]]/g, '');
                }
                return str;
            };

            return {
                summary: sanitizeString(parsedData.summary || "Health Guidance"),
                recommendations: Array.isArray(parsedData.recommendations)
                    ? parsedData.recommendations
                    : (parsedData.recommendations ? [sanitizeString(parsedData.recommendations)] : []),
                culturalTips: sanitizeString(parsedData.culturalTips || ""),
                warningSigns: sanitizeString(parsedData.warningSigns || ""),
                riskLevel: sanitizeString(parsedData.riskLevel || "Medium Risk"),
                structuredData: parsedData.structuredData !== false
            };
        } catch (error) {
            console.error('Gemini API Error:', error);
            // Even on API error, return a valid response to prevent client hang
            return {
                summary: "Service temporarily unavailable. Please try again.",
                riskLevel: "Unknown",
                error: true
            };
        }
    }
}

module.exports = new GeminiService();
