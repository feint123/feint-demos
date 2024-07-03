'use strict';

const { merge } = require('webpack-merge');

const common = require('./webpack.common.js');
const PATHS = require('./paths');

// Merge webpack configuration files
const config = merge(common, {
  entry: {
    popup: PATHS.src + '/popup.js',
    searchMode: PATHS.src + '/searchMode.js',
    cinemaMode: PATHS.src + '/cinemaMode.js',
    background: PATHS.src + '/background.js',
    iosSwitch: PATHS.src + '/iosSwitch.js',
    storage: PATHS.src + '/storage.js',
    accordion: PATHS.src + '/accordion.js',
    localCollect: PATHS.src + '/localCollect.js',
    keywordFilter: PATHS.src + '/keywordFilter.js',
    default: PATHS.src + '/default.js'
  },
});

module.exports = config;
