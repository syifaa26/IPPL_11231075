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

    // ---- Optimasi: Single Call Strategy (Vision + JSON) ----

    // Fungsi helper untuk generate content dengan retry/fallback
    const generateWithFallback = async (primaryModelName, fallbackModelName) => {
      let currentModelName = primaryModelName;
      let model = genAI.getGenerativeModel({
        model: currentModelName,
        generationConfig: { responseMimeType: "application/json" }
      });

      const prompt = `
        Analisis gambar makanan ini dan berikan estimasi nutrisi secara detail.
        
        Output HARUS berupa JSON murni dengan format berikut:
        {
          "description": "Nama makanan singkat (contoh: Nasi Goreng)",
          "foodDescription": "Deskripsi visual yang menjelaskan komposisi makanan (contoh: Nasi goreng kecokelatan dengan telur mata sapi dan irisan timun).",
          "calories": 0, // estimasi kalori total (integer)
          "protein": 0,  // gram (integer)
          "carbs": 0,    // gram (integer)
          "fat": 0,      // gram (integer)
          "fiber": 0,    // gram (integer)
          "sugar": 0,    // gram (integer)
          "salt": 0      // gram (integer)
        }
        
        Pastikan angka adalah estimasi yang realistis untuk 1 porsi standar yang terlihat di gambar.
        `;

      const requestParts = [
        { text: prompt },
        {
          inlineData: {
            data: imageData,
            mimeType,
          },
        },
      ];

      try {
        console.log(`Trying model: ${currentModelName}`);
        const result = await model.generateContent(requestParts);
        return { result, usedModel: currentModelName };
      } catch (error) {
        // Jika error 429 (Rate Limit) dan ada fallback
        if ((error.status === 429 || (error.message && error.message.includes("429"))) && fallbackModelName) {
          console.warn(`Model ${currentModelName} limit. Switching to fallback: ${fallbackModelName}`);
          currentModelName = fallbackModelName;
          model = genAI.getGenerativeModel({
            model: currentModelName,
            generationConfig: { responseMimeType: "application/json" }
          });
          const result = await model.generateContent(requestParts);
          return { result, usedModel: currentModelName };
        }
        throw error; // Lempar error jika bukan 429 atau retry gagal
      }
    };

    const primaryModel = process.env.GENERATIVE_MODEL || "gemini-2.5-flash";
    const fallbackModel = "gemini-1.5-flash"; // Model cadangan yang lebih stabil/cepat

    const { result, usedModel } = await generateWithFallback(primaryModel, fallbackModel);

    const responseText = result.response.text();
    const modelName = usedModel;

    // Parsing & Cleaning JSON
    let cleanedText = responseText
      .replace(/```json/gi, '')
      .replace(/```/g, '')
      .trim();

    let jsonResponse;
    try {
      jsonResponse = JSON.parse(cleanedText);
    } catch (e) {
      // Fallback cleanup using regex if simple parse fails
      const match = cleanedText.match(/\{[\s\S]*\}/);
      if (match) {
        jsonResponse = JSON.parse(match[0]);
      } else {
        console.error("Failed to parse JSON:", cleanedText);
        throw new Error("Gagal parsing JSON dari respons Gemini");
      }
    }

    res.json({
      ...jsonResponse,
      model: modelName,
    });

  } catch (err) {
    console.error("Error detail:", err);

    // Handle status 429 explicitly (Quota Exceeded)
    if (err.status === 429 || (err.message && err.message.includes("429"))) {
      return res.status(429).json({
        error: "Quota Exceeded",
        message: "Limit Gemini Free Tier habis (20 req/menit). Mohon tunggu sebentar.",
        retryDelay: 10
      });
    }

    res.status(500).json({
      error: "Server Error",
      message: err.message
    });
  }
});

module.exports = router;
