// routes/auth.js
const express = require('express');
const router = express.Router();
const pool = require('../db');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// REGISTER (kalıcı güvenli)
router.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    if (!name || !email || !password) return res.status(400).json({ message: 'Eksik bilgi' });

    const hashed = await bcrypt.hash(password, 10);
    const inserted = await pool.query(
      'INSERT INTO users (name, email, password) VALUES ($1,$2,$3) RETURNING id,name,email',
      [name, email, hashed]
    );

    res.json({ message: 'Kayıt başarılı', user: inserted.rows[0] });
  } catch (err) {
    console.error('❌ Register hatası:', err.message);
    res.status(500).send('Sunucu hatası: ' + err.message);
  }
});

// LOGIN (sadece hash doğrula)
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ message: 'E-posta ve şifre gerekli' });

    const q = await pool.query('SELECT * FROM users WHERE email=$1', [email]);
    if (q.rows.length === 0) return res.status(404).json({ message: 'Kullanıcı bulunamadı' });

    const user = q.rows[0];
    const valid = await bcrypt.compare(password, user.password);
    if (!valid) return res.status(401).json({ message: 'Geçersiz şifre' });

    const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, { expiresIn: '2h' });
    res.json({ message: 'Giriş başarılı', token, user: { id: user.id, name: user.name, email: user.email } });
  } catch (err) {
    console.error('❌ Login hatası:', err.message);
    res.status(500).send('Sunucu hatası: ' + err.message);
  }
});

module.exports = router;
