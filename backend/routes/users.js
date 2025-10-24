const express = require('express');
const router = express.Router();
const pool = require('../db');

// Tüm kullanıcıları getir
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users ORDER BY id ASC');
    res.json(result.rows);
  } catch (err) {
    res.status(500).send('Sunucu hatası: ' + err.message);
  }
});

// Tek kullanıcıyı getir
router.get('/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users WHERE id=$1', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).send('Kullanıcı bulunamadı');
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).send('Sunucu hatası: ' + err.message);
  }
});

module.exports = router;
