"use strict";

const Parser = require("rss-parser");
const loopFeed = require("./loopfeed");

// Configure parser with better options
const parser = new Parser({
  timeout: 10000,  // 10 second timeout (increased from 5s)
  headers: {
    'User-Agent': 'AWS-RSS-Checker/1.0'
  },
  maxRedirects: 3
});

/**
 * Parse RSS feed and process items
 */
module.exports = async (siteId, feedUrl) => {
  console.log(`Starting RSS parse for ${siteId}: ${feedUrl}`);
  
  try {
    // Basic URL validation
    if (!feedUrl || !feedUrl.startsWith('http')) {
      throw new Error(`Invalid feed URL: ${feedUrl}`);
    }

    const feed = await parser.parseURL(feedUrl);
    
    if (!feed) {
      throw new Error('No feed data received');
    }

    if (!feed.items || !Array.isArray(feed.items)) {
      console.warn(`No items found in feed: ${feed.title || siteId}`);
      return;
    }

    console.log(`Successfully parsed RSS feed: ${feed.title || siteId}`, {
      itemCount: feed.items.length
    });

    // Process feed items
    await loopFeed(feed, siteId);
    
    return {
      success: true,
      feedTitle: feed.title,
      itemCount: feed.items.length
    };

  } catch (error) {
    // Enhanced error logging with context
    console.error(`RSS parsing failed for ${siteId}:`, {
      feedUrl: feedUrl ? feedUrl.substring(0, 100) : 'undefined',
      error: error.message,
      errorType: error.name
    });

    // Re-throw with enhanced context for upstream handling
    const enhancedError = new Error(`RSS parsing failed for ${siteId}: ${error.message}`);
    enhancedError.originalError = error;
    enhancedError.feedUrl = feedUrl;
    enhancedError.siteId = siteId;
    
    throw enhancedError;
  }
};
