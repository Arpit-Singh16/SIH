// middleware/languageDetector.js
const User = require('../models/User');

const languageDetector = {
  name: 'userLanguageDetector',
  lookup: async (req, res, options) => {
    if (req.user && req.user._id) {
      try {
        const user = await User.findById(req.user._id);
        return user.languagePreference || 'en';
      } catch (error) {
        return 'en';
      }
    }
    return 'en';
  },
  cacheUserLanguage: (req, res, lng, options) => {
    // Optionally cache the language
  }
};

module.exports = languageDetector;