const express = require("express");
const router = express.Router();
const pool = require("../db");
const authMiddleware = require("../middleware/auth"); // 🔒 kullanıcı doğrulama eklendi

// 🔹 Tüm asset işlemleri artık kimlik doğrulama ister
router.use(authMiddleware);

// 🔹 KULLANICIYA GÖRE TÜM VARLIKLARI GETİR
router.get("/", async (req, res) => {
  try {
    const userId = req.user.userId; // token’dan geldi

    const result = await pool.query(
      `
      SELECT a.id, a.name, a.amount, a.unit_value, a.total_value,
             at.name AS type_name, c.code AS currency_code
      FROM assets a
      JOIN asset_types at ON a.type_id = at.id
      JOIN currencies c ON a.currency_id = c.id
      WHERE a.user_id = $1
      ORDER BY a.id;
    `,
      [userId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error("❌ GET /assets hatası:", err.message);
    res.status(500).send("Sunucu hatası: " + err.message);
  }
});

// 🔹 YENİ VARLIK EKLE veya VAR OLANI GÜNCELLE
router.post("/", async (req, res) => {
  try {
    const userId = req.user.userId; // token’daki userId
    const { type_id, currency_id, name, amount, unit_value } = req.body;

    // 🔍 Aynı isim + tür + para birimi zaten varsa güncelle
    const existing = await pool.query(
      `SELECT * FROM assets 
       WHERE user_id = $1 AND name = $2 AND type_id = $3 AND currency_id = $4`,
      [userId, name, type_id, currency_id]
    );

    if (existing.rows.length > 0) {
      const updated = await pool.query(
        `UPDATE assets 
         SET amount = amount + $1,
             unit_value = $2
         WHERE id = $3
         RETURNING *`,
        [amount, unit_value, existing.rows[0].id]
      );

      return res.json({
        message: "✅ Mevcut varlık güncellendi",
        asset: updated.rows[0],
      });
    }

    // 🆕 Yeni kayıt ekle
    const inserted = await pool.query(
      `INSERT INTO assets (user_id, type_id, currency_id, name, amount, unit_value)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [userId, type_id, currency_id, name, amount, unit_value]
    );

    res.json({
      message: "🆕 Yeni varlık eklendi",
      asset: inserted.rows[0],
    });
  } catch (err) {
    console.error("❌ POST /assets hatası:", err.message);
    res.status(500).send("Ekleme/Güncelleme hatası: " + err.message);
  }
});

// 🔹 VARLIK GÜNCELLE
router.put("/:id", async (req, res) => {
  try {
    const userId = req.user.userId; // kimlik doğrulama
    const { name, amount, unit_value } = req.body;
    const { id } = req.params;

    const updated = await pool.query(
      `UPDATE assets 
       SET name = $1, amount = $2, unit_value = $3 
       WHERE id = $4 AND user_id = $5
       RETURNING *`,
      [name, amount, unit_value, id, userId]
    );

    if (updated.rowCount === 0) {
      return res
        .status(404)
        .json({ message: "Varlık bulunamadı veya erişim izni yok" });
    }

    res.json({ message: "✅ Varlık güncellendi", asset: updated.rows[0] });
  } catch (err) {
    console.error("❌ PUT /assets hatası:", err.message);
    res.status(500).send("Güncelleme hatası: " + err.message);
  }
});

// 🔹 VARLIK SİL
router.delete("/:id", async (req, res) => {
  try {
    const userId = req.user.userId; // kimlik kontrolü
    const { id } = req.params;

    const result = await pool.query(
      "DELETE FROM assets WHERE id = $1 AND user_id = $2 RETURNING *",
      [id, userId]
    );

    if (result.rowCount === 0) {
      return res
        .status(404)
        .json({ message: "Varlık bulunamadı veya erişim izni yok" });
    }

    res.json({ message: "✅ Varlık silindi", deleted: result.rows[0] });
  } catch (err) {
    console.error("❌ DELETE /assets hatası:", err.message);
    res.status(500).send("Silme hatası: " + err.message);
  }
});

module.exports = router;
