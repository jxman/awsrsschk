"use strict";

const axios = require("axios");
const striptags = require("striptags");

// Configure axios with better defaults
const httpClient = axios.create({
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
    'User-Agent': 'AWS-RSS-Checker/1.0'
  }
});

/**
 * Send notification to Microsoft Teams
 */
module.exports = async (vendor, time, summary, detail, urlAlert) => {
  const prodHook = process.env.PROD_HOOK;
  
  if (!prodHook) {
    throw new Error('PROD_HOOK environment variable not configured');
  }

  // Validate required inputs
  if (!vendor || !summary) {
    throw new Error('Missing required fields: vendor and summary are required');
  }

  // Clean and limit content to prevent Teams message issues
  const cleanDetail = striptags(detail || '').substring(0, 1000);
  const cleanSummary = summary.substring(0, 200);
  
  console.log(`Sending webhook notification for ${vendor}: ${cleanSummary.substring(0, 50)}...`);

  const payload = {
    type: "message",
    summary: `${vendor} - ${cleanSummary}`,
    attachments: [{
      contentType: "application/vnd.microsoft.card.adaptive",
      contentUrl: null,
      content: {
        $schema: "http://adaptivecards.io/schemas/adaptive-card.json",
        type: "AdaptiveCard",
        version: "1.2",
        body: [
          {
            type: "TextBlock",
            text: `🚨 ${vendor} Status Update`,
            wrap: true,
            weight: "Bolder",
            size: "Medium",
            color: "Attention"
          },
          {
            type: "TextBlock",
            text: cleanSummary,
            wrap: true,
            weight: "Bolder"
          },
          {
            type: "TextBlock",
            text: `📅 ${time}`,
            isSubtle: true,
            spacing: "Small"
          },
          {
            type: "TextBlock",
            text: cleanDetail,
            wrap: true,
            spacing: "Medium"
          }
        ],
        actions: urlAlert ? [{
          type: "Action.OpenUrl",
          title: "View Status Page",
          style: "positive",
          url: urlAlert
        }] : []
      }
    }]
  };

  try {
    const response = await httpClient.post(prodHook, payload);
    
    console.log(`Webhook sent successfully for ${vendor}`, {
      status: response.status,
      statusText: response.statusText
    });

    return {
      success: true,
      vendor,
      summary: cleanSummary
    };

  } catch (error) {
    console.error(`Webhook delivery failed for ${vendor}:`, {
      error: error.message,
      status: error.response?.status,
      statusText: error.response?.statusText
    });

    // Don't throw error to prevent blocking other notifications
    // Log error and continue
    return {
      success: false,
      vendor,
      error: error.message
    };
  }
};
