const express = require('express');
const router = express.Router();
const newsController = require('../controllers/news.controller');

// GET /api/top-headlines
router.get('/top-headlines', newsController.getTopHeadlines);

// GET /api/search
router.get('/search', newsController.searchNews);

// New favorite routes
router.get('/favorites', newsController.getFavorites);
router.post('/favorites', newsController.addToFavorites);
router.delete('/favorites/:articleId', newsController.removeFromFavorites);

module.exports = router;