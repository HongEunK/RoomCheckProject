const express = require('express');
const db = require('../db');

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT NOW() AS now');
    res.json({ serverTime: rows[0].now });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB 연결 실패' });
  }
});

module.exports = router;
