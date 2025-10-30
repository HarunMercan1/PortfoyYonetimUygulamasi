const express = require("express");
const router = express.Router();
const pool = require("../db");

// Tüm hisseleri getir
router.get("/", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT symbol, name, price_try FROM stocks ORDER BY name;"
    );
    res.json(result.rows);
  } catch (err) {
    console.error("❌ GET /stocks hatası:", err.message);
    res.status(500).send("Sunucu hatası: " + err.message);
  }
});

module.exports = router;
