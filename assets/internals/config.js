const { resolve } = require('path');
const pullAll = require('lodash/pullAll');
const uniq = require('lodash/uniq');

const PhoenixTemplate = {
  root: resolve(__dirname, '..'),
  build_to: resolve(__dirname, '..', '..', 'priv', 'static'),

  // This refers to the gsmlg phoenix template version this project is based on.
  version: '1.0.0',

};

module.exports = PhoenixTemplate;
