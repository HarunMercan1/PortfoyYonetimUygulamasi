const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT t.*, a.name AS asset_name
      FROM transactions t
      JOIN assets a ON t.asset_id = a.id
      ORDER BY t.created_at DESC;
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).send('Sunucu hatası: ' + err.message);
  }
});

module.exports = router;
