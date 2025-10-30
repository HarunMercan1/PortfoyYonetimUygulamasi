const express = require("express");
const router = express.Router();
const pool = require("../db");

// 🔹 Tüm kripto paraları getir
router.get("/", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM cryptos ORDER BY name");
    res.json(result.rows);
  } catch (err) {
    console.error("❌ GET /cryptos hatası:", err.message);
    res.status(500).send("Sunucu hatası: " + err.message);
  }
});

module.exports = router;
