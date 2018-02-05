'use strict';

// Twilio response
// adapted from https://cloud.google.com/community/tutorials/cloud-functions-twilio-sms
//
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const twilio = require('twilio');
const config = require('./config.json');
const MessagingResponse = twilio.twiml.MessagingResponse;
admin.initializeApp(functions.config().firebase);

exports.replyToSms = functions.https.onRequest((request, response) => {
  let isValid = true;
  
  // Only validate that requests came from Twilio when the function has been
  // deployed to production.
  if (process.env.NODE_ENV === 'production') {
    isValid = twilio.validateExpressRequest(request, config.TWILIO_AUTH_TOKEN, {
      url: `https://${config.GCLOUD_REGION}-${config.GFIREBASE_PROJECTID}.cloudfunctions.net/replyToSms`
    });
  }

  // Halt early if the request was not sent from Twilio
  if (!isValid) {
    response
      .type('text/plain')
      .status(403)
      .send('Twilio Request Validation Failed.')
      .end();
    return;
  }

  // Prepare a response to the SMS message
  const messagingResponse = new MessagingResponse();

  // Add text to the response
  messagingResponse.message('Hello from Google Cloud Functions! You sent a message to ' + request.body['To'] + ' from ' + request.body['From']);

  // Send the response
  response
    .status(200)
    .type('text/xml')
    .end(messagingResponse.toString());
  return;
});
