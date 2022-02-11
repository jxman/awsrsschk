"use strict";
const Parser = require("rss-parser");
const loopFeed = require("./loopfeed");

module.exports = async (siteId, feedurl) => {
  let parser = new Parser({ timeout: 5000 }); // create parser object with 5 second timeout
  try {
    let feed = await parser.parseURL(feedurl);
    console.log(`OK - ${feed.title} parsed`);
    await loopFeed(feed, siteId);
  } catch (error) {
    console.log(`ERROR - rsscheck - ${feedurl} - ${error}`);
  }
};
