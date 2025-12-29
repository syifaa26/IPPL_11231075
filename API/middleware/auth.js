// middleware/auth.js

module.exports = function (req, res, next) {
  // Jika tidak memakai autentikasi, otomatis lolos
  next();
};
