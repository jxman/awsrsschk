"use strict";
const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");

module.exports = async (x, y, z) => {
  const curDate = new Date().toISOString(); //get current date
  const client = new DynamoDBClient({ region: process.env.AWS_REGION });
  const params = {
    Item: {
      guidItem: { S: x },
      latestDate: { S: y },
      statusId: { S: z },
      sentDate: { S: curDate },
    },
    TableName: process.env.DYNAMO_SENT,
  };
  const command = new PutItemCommand(params);
  try {
    await client.send(command);
    console.log(`OK - db put ${y}`);
  } catch (error) {
    console.log(`ERROR - ${error}`);
  } finally {
    // finally.
  }
};
