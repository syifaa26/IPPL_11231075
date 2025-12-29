require('dotenv').config();
const express = require('express');
const app = express();
const cors = require('cors');

console.log("=== SERVER.JS DIMUAT ===");

app.use(cors());
// Izinkan payload JSON besar (base64 gambar) hingga 10MB
app.use(express.json({ limit: '10mb' }));


console.log("Loading routes...");
app.use('/api/ai', require('./routes/analyze-image'));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log("Server berjalan di port " + PORT);
});
