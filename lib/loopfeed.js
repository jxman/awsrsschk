"use strict";
const sendSlack = require("./webhook");
const putStatus = require("./dynamoput");
const getStatus = require("./dynamoget");

module.exports = async (feed, siteId) => {
  const curDate = new Date().toISOString(); //get current date

  // loops through items in RSS feed and sends webhook alert for new matching items
  for (let item of feed.items.reverse()) {
    if (
      Date.parse(item.pubDate) >
        Date.parse(curDate) - process.env.DATE_OFFSET &&
      Date.parse(item.pubDate) < Date.parse(curDate)
    ) {
      let stat = await getStatus(item.guid, item.pubDate);
      if (stat === false) {
        console.log(`Not Found ${item.guid} - ${item.pubDate}`);
        await putStatus(item.guid, item.pubDate, siteId); // if guid is not in DB (ie. false) write guid and send webhook

        await sendSlack(
          siteId,
          item.pubDate,
          item.title,
          item.content,
          item.guid
        ).catch((err) => console.log(`ERROR - slack call fail - ${err}`));
      } else {
        console.log(`Found ${item.guid} - ${item.pubDate}`);
      }
    }
    // console.log(item.guid + " - " + item.pubDate + " - " + curDate);
  }
  console.log(`Finish Loop for ${siteId}`);
};
