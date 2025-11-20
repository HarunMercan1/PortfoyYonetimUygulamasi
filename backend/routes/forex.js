const express = require("express");
const router = express.Router();
const pool = require("../db");

router.get("/", async (req, res) => {
  try {
    const r = await pool.query("SELECT * FROM forex ORDER BY symbol;");
    res.json(r.rows);
  } catch (err) {
    res.status(500).send("Döviz listesi getirilemedi: " + err.message);
  }
});

module.exports = router;
