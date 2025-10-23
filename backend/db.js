const { Pool } = require('pg');
require('dotenv').config();

// PostgreSQL bağlantı havuzu oluştur
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

// Bağlantı test
pool.connect()
  .then(() => console.log('✅ PostgreSQL baglantisi basarili'))
  .catch(err => console.error('❌ PostgreSQL baglanti hatasi:', err));

module.exports = pool;
