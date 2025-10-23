const express = require('express');
const router = express.Router();
const pool = require('../db');

// Tum varliklari getir (GET)
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM assets');
    res.json(result.rows);
  } catch (err) {
    console.error('❌ Veri cekme hatasi:', err);
    res.status(500).send('Sunucu hatasi');
  }
});

// Yeni varlik ekle (POST)
router.post('/', async (req, res) => {
  try {
    const { name, type, value } = req.body;
    const result = await pool.query(
      'INSERT INTO assets (name, type, value) VALUES ($1, $2, $3) RETURNING *',
      [name, type, value]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error('❌ Veri ekleme hatasi:', err);
    res.status(500).send('Sunucu hatasi');
  }
});

// Bir varligi guncelle (PUT)
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, type, value } = req.body;

    const result = await pool.query(
      'UPDATE assets SET name=$1, type=$2, value=$3 WHERE id=$4 RETURNING *',
      [name, type, value, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Varlik bulunamadi' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('❌ Veri guncelleme hatasi:', err);
    res.status(500).send('Sunucu hatasi');
  }
});

// Bir varligi sil (DELETE)
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM assets WHERE id=$1 RETURNING *',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Varlik bulunamadi' });
    }

    res.json({ message: 'Varlik basariyla silindi ✅' });
  } catch (err) {
    console.error('❌ Veri silme hatasi:', err);
    res.status(500).send('Sunucu hatasi');
  }
});



module.exports = router;
