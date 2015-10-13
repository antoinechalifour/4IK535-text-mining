'use strict';

/**
 * Node script to launch from the command line to sanitize tweets 
 * by removing username, links, hashtags, tweeter-related vocabulary (RT, FAV)
 *
 * Usage : node sanitize-tweets <path/to/file.json>
 *
 * Output in <path/to/file.json>-sanitized.json
 */

var fs = require('fs');

// Imports the sinitizer
var sanitize = require('./sanitizer');

var args = process.argv;
var file = args[2];

var data = require(`./${file}`);

var sanitized = data.map((tweet) => {
  var san = tweet;
  san.text = sanitize(tweet.text);

  return san;
});

fs.writeFileSync(`${file}-sanitized.json`, JSON.stringify(sanitized, null, 2));
