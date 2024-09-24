// postcss.config.js

const purgecss = require('@fullhuman/postcss-purgecss')({
  content: [
    './layouts/**/*.html',
    './content/**/*.md',
    './themes/**/*.layouts/**/*.html',
    // Ajoutez d'autres chemins si nécessaire
  ],
  defaultExtractor: content => content.match(/[\w-/:]+(?<!:)/g) || []
});

module.exports = {
  plugins: [
    purgecss,
    require('cssnano')({
      preset: 'default',
    }),
  ],
};
