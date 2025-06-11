"use strict";
const { DynamoDBClient, GetItemCommand } = require("@aws-sdk/client-dynamodb");

module.exports = async (x, y) => {
  const client = new DynamoDBClient({ region: process.env.AWS_REGION });
  const params = {
    Key: { guidItem: { S: x } },
    TableName: process.env.DYNAMO_SENT,
  };
  const command = new GetItemCommand(params);
  try {
    const results = await client.send(command);
    console.log(`OK - db get - ${x}`);
    //let exists = false;
    if (results.Item != null && results.Item.latestDate.S == y) {
      //if item found and the dates match return true
      return true;
    } else {
      return false; // if not return false and send notification and update DB
    }
  } catch (error) {
    console.log(`ERROR - db get - ${error}`);
  } finally {
    // finally.
  }
};
