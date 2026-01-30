require('dotenv').config();
const app = require('./src/app');

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
    console.log(`API Key configured: ${process.env.GEMINI_API_KEY ? 'Yes' : 'No'}`);
    console.log(`Accepting connections from all network interfaces.`);
});
