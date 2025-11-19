// middleware/auth.js
const jwt = require('jsonwebtoken');

function authMiddleware(req, res, next) {
  const token = req.header('Authorization')?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ message: 'Token bulunamadı' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // ✅ burada id varsa onu userId olarak ata
    req.user = {
  userId: decoded.id,
  email: decoded.email,
  role: decoded.role
};


    next();
  } catch (err) {
    console.error('❌ Token doğrulama hatası:', err.message);
    res.status(401).json({ message: 'Geçersiz token' });
  }
}

module.exports = authMiddleware;
