const express = require('express');
const router = express.Router();
const pool = require('../db');

// 🔹 TÜM VARLIKLARI GETİR (JOIN ile)
router.get('/', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT a.id, a.name, a.amount, a.unit_value, a.total_value,
             at.name AS type_name, c.code AS currency_code, u.name AS user_name
      FROM assets a
      JOIN asset_types at ON a.type_id = at.id
      JOIN currencies c ON a.currency_id = c.id
      JOIN users u ON a.user_id = u.id
      ORDER BY a.id;
    `);
    res.json(result.rows);
  } catch (err) {
    console.error('❌ GET /assets hatası:', err.message);
    res.status(500).send('Sunucu hatası: ' + err.message);
  }
});

// 🔹 YENİ VARLIK EKLE veya VAR OLANI GÜNCELLE
router.post('/', async (req, res) => {
  try {
    const { user_id, type_id, currency_id, name, amount, unit_value } = req.body;

    // 🔍 aynı kullanıcı + aynı isim + aynı tür + aynı para birimi varsa bul
    const existing = await pool.query(
      `SELECT * FROM assets 
       WHERE user_id = $1 AND name = $2 AND type_id = $3 AND currency_id = $4`,
      [user_id, name, type_id, currency_id]
    );

    if (existing.rows.length > 0) {
      // 🔁 varsa sadece miktar & birim fiyat güncelle
      const updated = await pool.query(
        `UPDATE assets 
         SET amount = amount + $1,
             unit_value = $2
         WHERE id = $3
         RETURNING *`,
        [amount, unit_value, existing.rows[0].id]
      );

      res.json({
        message: '✅ Mevcut varlık güncellendi',
        asset: updated.rows[0],
      });
    } else {
      // 🆕 yoksa yeni kayıt ekle (total_value'yu PostgreSQL kendisi hesaplayacak)
      const inserted = await pool.query(
        `INSERT INTO assets (user_id, type_id, currency_id, name, amount, unit_value)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING *`,
        [user_id, type_id, currency_id, name, amount, unit_value]
      );

      res.json({
        message: '🆕 Yeni varlık eklendi',
        asset: inserted.rows[0],
      });
    }
  } catch (err) {
    console.error('❌ POST /assets hatası:', err.message);
    res.status(500).send('Ekleme/Güncelleme hatası: ' + err.message);
  }
});

module.exports = router;
