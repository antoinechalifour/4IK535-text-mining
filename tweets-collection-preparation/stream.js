'use strict';

/**
 * Streams tweets tracked by the given keyword. Stores the result in
 * an array when user presses ctrl+c.
 *
 * Usage : node stream <your_keyword>
 * Output : tweets-<keyword>.json
 */

var args = process.argv;
var fs = require('fs');
var Twit = require('twit');
var isSaved = false

/**
 * @param  {Array} an array of streamed tweets
 * @param  {String} the tracked keyword
 * @return {undefined}
 */
function save(tweets, keyword){
  var filename = `tweets-${keyword}.json`;
  return function(){
    if(!isSaved){
      console.log('Saving tweets...');
      fs.writeFileSync(filename, JSON.stringify(tweets, null, 2));
      console.log(`Tweets saved in file ${filename}`);
      isSaved = true;
      process.exit();
    }
  }
}

var keyword = args[2];
var tweets = [];
var credentials = require('./credentials');
var t = new Twit(credentials);

if(args.length != 3){
  return console.error('Error : usage - node stream <keyword>');
}

var stream = t.stream('statuses/filter', {
  track: keyword
});

stream.on('tweet', tweet => {
  tweets.push({
    created_at: tweet.created_at,
    id: tweet.id,
    text: tweet.text,
    geo: tweet.geo,
    coordinates: tweet.coordinates,
    lang: tweet.lang,
    timestamp_ms: tweet.timestamp_ms
  });
  process.stdout.cursorTo(0);
  process.stdout.write(`${tweets.length} tweets collected`);
});

process.on('exit', save(tweets, keyword));
process.on('SIGINT', save(tweets, keyword));
process.on('uncaughtException', save(tweets, keyword));
