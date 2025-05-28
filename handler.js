"use strict";

const checkRss = require("./lib/checkrss");
const { DynamoDBClient, ScanCommand } = require("@aws-sdk/client-dynamodb");

// Initialize DynamoDB client outside handler for connection reuse
const client = new DynamoDBClient({ 
  region: process.env.AWS_REGION,
  maxAttempts: 3,
  retryMode: 'adaptive'
});

/**
 * Main Lambda handler for RSS status checking
 */
module.exports.run = async (event, context, callback) => {
  console.log('Starting RSS check process', {
    requestId: context.awsRequestId,
    stage: process.env.ENVIRONMENT,
    timestamp: new Date().toISOString()
  });

  const params = { 
    TableName: process.env.DYNAMO_TABLE,
    ConsistentRead: true  // Better data accuracy
  };

  try {
    const command = new ScanCommand(params);
    const results = await client.send(command);
    
    console.log(`Retrieved ${results.Items?.length || 0} RSS feeds to check`);

    if (!results.Items || results.Items.length === 0) {
      console.warn('No RSS feeds found in database');
      return callback(null, {
        statusCode: 200,
        body: JSON.stringify({ message: 'No RSS feeds configured' })
      });
    }

    let successCount = 0;
    let errorCount = 0;

    // Process feeds with better error handling
    for (const item of results.Items) {
      const feedUrl = item.rssUrl?.S;
      const siteId = item.statusId?.S;

      if (!feedUrl || !siteId) {
        console.warn('Invalid feed configuration:', { item });
        continue;
      }

      try {
        console.log(`Processing RSS feed: ${siteId}`);
        await checkRss(siteId, feedUrl);
        successCount++;
        console.log(`Successfully processed: ${siteId}`);
      } catch (error) {
        errorCount++;
        console.error(`Failed to process feed ${siteId}:`, {
          error: error.message,
          feedUrl: feedUrl.substring(0, 100) // Truncate for logging
        });
        // Continue processing other feeds even if one fails
      }
    }

    console.log('RSS check process completed', {
      totalFeeds: results.Items.length,
      successful: successCount,
      errors: errorCount
    });

    // Return success even if some feeds failed
    return callback(null, {
      statusCode: 200,
      body: JSON.stringify({
        message: 'RSS check completed',
        successful: successCount,
        errors: errorCount
      })
    });

  } catch (error) {
    console.error('Critical error in RSS checker:', {
      error: error.message,
      requestId: context.awsRequestId
    });

    return callback(null, {
      statusCode: 500,
      body: JSON.stringify({
        error: 'Internal server error',
        requestId: context.awsRequestId
      })
    });
  }
};
