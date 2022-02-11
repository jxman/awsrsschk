"use strict";
const checkRss = require("./lib/checkrss");
const { DynamoDBClient, ScanCommand } = require("@aws-sdk/client-dynamodb");

module.exports.run = async (event, context, callback) => {
  const params = { TableName: process.env.DYNAMO_TABLE };
  const client = new DynamoDBClient({ region: process.env.AWS_REGION });
  const command = new ScanCommand(params);
  try {
    const results = await client.send(command); // call DynamoDB and scan for all records to pull rss urls
    console.log("OK - db scan load sites");

    // loops through all the records in the DynamoDB and calls the chcekRss feed with the appropritate variables
    for (let i of results.Items) {
      let awsStatusfeed = i.rssUrl.S;
      let siteId = i.statusId.S;

      console.log("Start rss call to " + siteId);
      await checkRss(siteId, awsStatusfeed);
      console.log("Finish rss call to " + siteId);
    }
  } catch (error) {
    console.log(`ERROR - db scan - ${error}`);
  }
};
