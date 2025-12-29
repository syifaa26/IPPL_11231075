const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// =======================
//   POST /api/ai (mount) -> '/'
// =======================
router.post('/', auth, async (req, res) => {
  try {
    const { imageData, mimeType } = req.body;

    if (!imageData || !mimeType) {
      return res.status(400).json({
        error: "imageData dan mimeType wajib dikirim"
      });
    }

    // imageData SUDAH base64 dari client, kirim langsung ke Gemini
    const modelName = process.env.GENERATIVE_MODEL || "gemini-2.5-flash";

    // ---- 1. Vision: Kenali makanan ----
    const visionModel = genAI.getGenerativeModel({ model: modelName });
    const visionPrompt = `
Analisis gambar ini. Sebutkan:
1. Jenis makanan yang terlihat
2. Porsi realistik

Format output hanya kalimat biasa tanpa bullet.
    `;

    const visionResult = await visionModel.generateContent([
      { text: visionPrompt },
      {
        inlineData: {
          data: imageData, // base64 langsung
          mimeType,
        },
      },
    ]);

    const foodDescription = visionResult.response.text();


    // ---- 2. Nutrisi: Analisis JSON nutrisi ----
    const textModel = genAI.getGenerativeModel({ model: modelName });

    const nutritionPrompt = `
Anda ahli gizi. Berdasarkan deskripsi makanan ini:

"${foodDescription}"

Berikan nutrisi dalam FORMAT JSON KETAT:

{
  "description": "text singkat",
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fat": 0,
  "sugar": 0,
  "salt": 0
}

Jangan beri teks lain, jangan gunakan tanda \`\`\`.
    `;

    const nutritionResult = await textModel.generateContent([{ text: nutritionPrompt }]);
    let nutritionText = nutritionResult.response.text() || '';

    // ---- 3. Bersihkan JSON ----
    let cleanedText = nutritionText
      .replace(/```json/gi, '')
      .replace(/```/g, '')
      .trim();

    const match = cleanedText.match(/\{[\s\S]*\}/);
    if (!match) {
      return res.status(500).json({
        error: 'Gagal parsing respons nutrisi',
        raw: nutritionText,
      });
    }

    cleanedText = match[0];

    let jsonResponse;
    try {
      jsonResponse = JSON.parse(cleanedText);
    } catch (e) {
      console.error('JSON parse error:', e, 'raw:', cleanedText);
      return res.status(500).json({
        error: 'Format JSON dari Gemini tidak valid',
        raw: nutritionText,
      });
    }

    res.json({
      ...jsonResponse,
      foodDescription,
      model: modelName,
    });

  } catch (err) {
    console.error("Error detail:", err);
    res.status(500).json({
      error: "Server Error",
      message: err.message
    });
  }
});

module.exports = router;
