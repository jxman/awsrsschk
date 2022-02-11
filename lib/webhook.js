"use strict";
const axios = require("axios");
const prodHook = process.env.PROD_HOOK;
// const testHook = process.env.TEST_HOOK;
// const url = slackHook;
const striptags = require("striptags");

module.exports = async (vendor, time, summary, detail, urlalert) => {
  console.log(urlalert);

  // const res = await axios.post(url, {
  //   text: `| **${vendor}** | **${summary}** | **${time}** |\n${striptags(
  //     detail
  //   )}\n<${urlalert}>`,
  // });

  const res = await axios.post(prodHook, {
    type: "message",
    summary: `${vendor} - ${summary}`,
    attachments: [
      {
        contentType: "application/vnd.microsoft.card.adaptive",
        contentUrl: null,
        content: {
          $schema: "http://adaptivecards.io/schemas/adaptive-card.json",
          type: "AdaptiveCard",
          version: "1.2",
          body: [
            {
              type: "TextBlock",
              text: `${vendor} - ${summary}`,
              wrap: true,
              weight: "Bolder",
            },

            {
              type: "TextBlock",
              text: `${time}`,
              isSubtle: true,
            },

            {
              type: "TextBlock",
              text: `${striptags(detail)}`,
              wrap: true,
            },
          ],
          actions: [
            {
              type: "Action.OpenUrl",
              title: "Vendor Status Page",
              style: "default",
              url: `${urlalert}`,
            },
          ],
        },
      },
    ],
  });

  console.log(`OK - slack sent - ${summary}`);
};
