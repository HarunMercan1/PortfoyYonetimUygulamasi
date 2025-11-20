const express = require("express");
const router = express.Router();
const pool = require("../db");

router.get("/", async (req, res) => {
  try {
    const r = await pool.query("SELECT * FROM funds ORDER BY name;");
    res.json(r.rows);
  } catch (err) {
    res.status(500).send("Fon listesi getirilemedi: " + err.message);
  }
});

module.exports = router;
