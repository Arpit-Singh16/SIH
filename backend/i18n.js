const i18next = require('i18next');
const Backend = require('i18next-fs-backend');
const middleware = require('i18next-http-middleware');
const path = require('path');
const userLanguageDetector = require('./middleware/languageDetector');

i18next
  .use(Backend)
  .use(middleware.LanguageDetector)
  .init({
    fallbackLng: 'en',
    preload: ['en', 'hi', 'pa'],
    ns: ['common', 'homepage', 'reports'],
    defaultNS: 'common',
    backend: {
      loadPath: path.join(__dirname, 'local/{{lng}}/{{ns}}.json'),
    },
    detection: {
      order: ['userLanguageDetector', 'header', 'session', 'querystring', 'cookie'],
      caches: ['cookie'],
      // Add custom detector
      detectors: [userLanguageDetector],
      lookupHeader: 'accept-language',
      lookupSession: 'lng',
      lookupQuerystring: 'lng',
      lookupCookie: 'i18next',
    },
  });

module.exports = i18next;