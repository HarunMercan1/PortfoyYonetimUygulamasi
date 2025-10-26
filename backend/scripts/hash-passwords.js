// node scripts/hash-passwords.js
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

(async () => {
  try {
    const res = await pool.query('SELECT id, password FROM users');
    for (const row of res.rows) {
      const pwd = row.password || '';
      // Zaten bcrypt mi? $2a / $2b ile başlar
      if (/^\$2[aby]\$/.test(pwd)) continue;

      const hashed = await bcrypt.hash(pwd, 10);
      await pool.query('UPDATE users SET password=$1 WHERE id=$2', [hashed, row.id]);
      console.log(`✅ user#${row.id} hash’lendi`);
    }
    console.log('🚀 Migration bitti');
  } catch (e) {
    console.error('❌ Migration hata:', e);
  } finally {
    await pool.end();
  }
})();
