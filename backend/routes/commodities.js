const express = require("express");
const router = express.Router();
const pool = require("../db");

// Tüm emtiaları getir
router.get("/", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT id, symbol, name, price_try, price_usd FROM commodities ORDER BY name"
    );
    res.json(result.rows);
  } catch (err) {
    console.error("❌ GET /commodities hatası:", err.message);
    res.status(500).send("Sunucu hatası: " + err.message);
  }
});

module.exports = router;
