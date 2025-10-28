const express = require('express');
const router = express.Router();
const pool = require('../db');

// Tüm hisseleri getir
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM stocks ORDER BY symbol');
    res.json(result.rows);
  } catch (err) {
    res.status(500).send('Sunucu hatası: ' + err.message);
  }
});

module.exports = router;
