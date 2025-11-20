const express = require("express");
const router = express.Router();
const pool = require("../db");

router.get("/", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT * FROM commodities ORDER BY name;
    `);

    res.json(result.rows);
  } catch (err) {
    console.error("❌ GET /commodities hatası:", err.message);
    res.status(500).send("Sunucu hatası: " + err.message);
  }
});

module.exports = router;
