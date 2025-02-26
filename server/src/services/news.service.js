const axios = require('axios');
const NodeCache = require('node-cache');
const dotenv = require('dotenv');
const mongoose = require('mongoose');

dotenv.config();

// Initialize cache with TTL of 15 minutes
const cache = new NodeCache({ stdTTL: 900 });

// Add Mongoose schema for favorites
const FavoriteSchema = new mongoose.Schema({
  articleId: String,
  article: Object,
  createdAt: { type: Date, default: Date.now }
});

const Favorite = mongoose.model('Favorite', FavoriteSchema);

class NewsService {
  constructor() {
    this.apiKey = process.env.NEWS_API_KEY;
    this.baseUrl = 'https://newsapi.org/v2';
    this.defaultLanguage = 'en';
  }

  /**
   * Get top headlines
   * @param {string} category - News category
   * @param {string} country - Country code (default: us)
   * @param {number} page - Page number
   * @param {number} pageSize - Number of articles per page
   * @returns {Promise<Array>} - Array of news articles
   */
  async getTopHeadlines(category = null, country = 'us', page = 1, pageSize = 10) {
    const cacheKey = `headlines-${category || 'all'}-${country}-${page}-${pageSize}`;
    
    // Check if data is in cache
    const cachedData = cache.get(cacheKey);
    if (cachedData) {
      return cachedData;
    }
    
    try {
      const url = `${this.baseUrl}/top-headlines`;
      const params = {
        country,
        apiKey: this.apiKey,
        page,
        pageSize,
      };
      
      if (category && category !== 'general') {
        params.category = category;
      }
      
      const response = await axios.get(url, { params });
      
      const articles = response.data.articles.map(article => ({
        ...article,
        category: category || 'general'
      }));
      
      // Store in cache
      cache.set(cacheKey, articles);
      
      return articles;
    } catch (error) {
      console.error('Error fetching top headlines:', error.message);
      return this._getFallbackArticles(category);
    }
  }

  /**
   * Search for news articles
   * @param {string} query - Search query
   * @param {string} category - Optional category to filter by
   * @param {number} page - Page number
   * @param {number} pageSize - Number of articles per page
   * @returns {Promise<Array>} - Array of news articles
   */
  async searchNews(query, category = null, page = 1, pageSize = 10) {
    const cacheKey = `search-${query}-${category || 'all'}-${page}-${pageSize}`;
    
    // Check if data is in cache
    const cachedData = cache.get(cacheKey);
    if (cachedData) {
      return cachedData;
    }
    
    try {
      const url = `${this.baseUrl}/everything`;
      const params = {
        q: query,
        language: this.defaultLanguage,
        sortBy: 'relevancy',
        apiKey: this.apiKey,
        page,
        pageSize,
      };
      
      const response = await axios.get(url, { params });
      
      let articles = response.data.articles;
      
      // Filter by category if provided
      if (category && category !== 'general') {
        // Note: The "everything" endpoint doesn't support category filtering
        // so we're applying a rudimentary filter here
        articles = articles.filter(article => {
          const content = `${article.title} ${article.description} ${article.content}`.toLowerCase();
          return content.includes(category.toLowerCase());
        });
      }
      
      articles = articles.map(article => ({
        ...article,
        category: category || 'general'
      }));
      
      // Store in cache
      cache.set(cacheKey, articles);
      
      return articles;
    } catch (error) {
      console.error('Error searching news:', error.message);
      return this._getFallbackArticles(category, query);
    }
  }

  /**
   * Get fallback articles when the API fails
   * @private
   * @param {string} category - News category
   * @param {string} query - Search query
   * @returns {Array} - Array of fallback news articles
   */
  _getFallbackArticles(category = 'general', query = null) {
    // Generate some fallback content
    const today = new Date();
    
    const fallbackArticles = [
      {
        title: query 
          ? `Latest Updates on ${query}` 
          : 'Breaking News Today',
        description: 'Unable to fetch real-time news at the moment. Please check back later.',
        content: 'We apologize for the inconvenience. Our news service is currently experiencing difficulties connecting to the news source. Please try again later.',
        url: null,
        urlToImage: null,
        publishedAt: today.toISOString(),
        source: {
          name: 'News App',
          id: 'newsapp'
        },
        author: 'News App Team',
        category: category
      }
    ];
    
    return fallbackArticles;
  }

  /**
   * Get all favorite articles
   */
  async getFavorites() {
    try {
      const favorites = await Favorite.find().sort('-createdAt');
      return favorites.map(f => f.article);
    } catch (error) {
      console.error('Error fetching favorites:', error);
      return [];
    }
  }

  /**
   * Add article to favorites
   */
  async addToFavorites(article) {
    try {
      const articleId = article.id || article.url || article.title;
      await Favorite.findOneAndUpdate(
        { articleId },
        { article },
        { upsert: true, new: true }
      );
    } catch (error) {
      console.error('Error adding to favorites:', error);
      throw error;
    }
  }

  /**
   * Remove article from favorites
   */
  async removeFromFavorites(articleId) {
    try {
      console.log('Attempting to remove favorite:', articleId);
      const result = await Favorite.deleteOne({ articleId });
      
      if (result.deletedCount === 0) {
        console.log('No favorite found with ID:', articleId);
        throw new Error('Favorite not found');
      }
      
      console.log('Successfully removed favorite:', articleId);
    } catch (error) {
      console.error('Error removing from favorites:', error);
      throw error;
    }
  }
}

module.exports = new NewsService();
