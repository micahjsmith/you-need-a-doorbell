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

  // Add the sender to the database
  let gatheringsRef = admin.database().ref('gatherings')
  let query = gatheringsRef.orderByChild('contact').equalTo(request.body['To'])
  query.once('value').then((snapshot) => {
    // TODO add validation that the event is happening right now
    for (var key in snapshot.val()) {
      gatheringsRef.child(key).child('arrivedGuests').push(request.body);
    }

    // Respond to the sender
    const messagingResponse = new MessagingResponse();
    messagingResponse.message('Thanks for ringing! Someone will come to open the door shortly.');
    response
      .status(200)
      .type('text/xml')
      .end(messagingResponse.toString());
    return;
  }).catch((error) => {
    console.error(error);

    // Respond to the sender
    const messagingResponse = new MessagingResponse();
    messagingResponse.message('There was an error ringing the doorbell. Please try again, or contact the host directly.');
    response
      .status(200)
      .type('text/xml')
      .end(messagingResponse.toString());

    return;
  });
});
