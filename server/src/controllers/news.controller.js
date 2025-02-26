const newsService = require('../services/news.service');

/**
 * Get top headlines
 */
exports.getTopHeadlines = async (req, res, next) => {
  try {
    const { category, country, page = 1, pageSize = 10 } = req.query;
    const articles = await newsService.getTopHeadlines(
      category || null,
      country || 'us',
      parseInt(page),
      parseInt(pageSize)
    );
    
    res.json({
      status: 'success',
      articles
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Search for news
 */
exports.searchNews = async (req, res, next) => {
  try {
    const { q, category, page = 1, pageSize = 10 } = req.query;
    
    if (!q) {
      return res.status(400).json({
        status: 'error',
        message: 'Search query is required'
      });
    }
    
    const articles = await newsService.searchNews(
      q,
      category || null,
      parseInt(page),
      parseInt(pageSize)
    );
    
    res.json({
      status: 'success',
      articles
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get favorite articles
 */
exports.getFavorites = async (req, res, next) => {
  try {
    const favorites = await newsService.getFavorites();
    res.json({
      status: 'success',
      articles: favorites
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Add article to favorites
 */
exports.addToFavorites = async (req, res, next) => {
  try {
    const article = req.body;
    await newsService.addToFavorites(article);
    res.json({
      status: 'success',
      message: 'Article added to favorites'
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Remove article from favorites
 */
exports.removeFromFavorites = async (req, res, next) => {
  try {
    const { articleId } = req.params;
    if (!articleId) {
      return res.status(400).json({
        status: 'error',
        message: 'Article ID is required'
      });
    }

    // Decode the URL-encoded articleId
    const decodedId = decodeURIComponent(articleId);
    console.log('Removing article with ID:', decodedId);

    await newsService.removeFromFavorites(decodedId);
    
    res.json({
      status: 'success',
      message: 'Article removed from favorites'
    });
  } catch (error) {
    console.error('Error in removeFromFavorites:', error);
    next(error);
  }
};