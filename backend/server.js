const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const pool = require('./db');
const assetsRoutes = require('./routes/assets'); // <-- BUNU EKLE

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// BURASI ÇOK ÖNEMLİ 🔥
app.use('/api/assets', assetsRoutes);

app.get('/', (req, res) => {
  res.send('Server ayakta ✅');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`🚀 Server ${PORT} portunda calisiyor...`));
