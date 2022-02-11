# AWS RSS Checker App

A Node.js app written and public to AWS Lambda using the servless framework (https://www.serverless.com/).

## Overview

The Lambda Function reads from a source list of RSS sites within DynamoDB (see example below) and then scans each site for any published status update. As the various providers publish updates to their respective sites, the script will capture the update and send the update to a defined webhook. Additionally, the “sent updates” are written to a DynamoDB table used to eliminate duplicate alerts for the same update.

Apigee https://status.apigee.com/history.rss
Azure https://azurestatuscdn.azureedge.net/en-us/status/feed/
CloudFlare https://www.cloudflarestatus.com/history.rss
Imperva https://status.imperva.com/history.rss
NewRelic https://status.newrelic.com/history.rss

## AWS Resources used include:

| DynamoDB | Lambda | Event Bridge | Cloudwatch |
