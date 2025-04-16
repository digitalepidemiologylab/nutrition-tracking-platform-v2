module.exports = {
  env: {
    browser: true,
    es2021: true,
  },
  extends: [
    'airbnb-base',
  ],
  parserOptions: {
    ecmaVersion: 13,
    sourceType: 'module',
  },
  ignorePatterns: [
    '/node_modules',
    '/app/assets/builds/*.js',
  ],
  rules: {
    'max-len': ['error', { code: 120 }],
    'class-methods-use-this': 'off',
    'no-alert': 'off',
  },
};
