from flask import Flask, request, redirect

import subprocess
import time

import twilio.twiml

app = Flask(__name__)

log_filename='/Users/micahsmith/partyapp/arrivals.log'
micah_number = "+15555551234"
already_arrived = []

@app.route("/", methods=['GET'])
def hello():
    subprocess.call(["say", "Hello World"])
    return "Hello World"

def announce(person):
    message = 'DING DONG. Guest {} has arrived to the party.'.format(person)
    subprocess.call(["say", message])

@app.route("/party_arrival", methods=['POST'])
def party_arrival():
    number = request.form['From']
    message_body = request.form['Body']

    if number == micah_number or number not in already_arrived:
        result = "announced"
        already_arrived.append(number)
        announce(message_body)
        resp = twilio.twiml.Response()
        resp.message('Someone is coming to open the door. (Make sure you are at the Cross St entrance.)')
        ret = str(resp)
    else:
        result = "repeat"
        resp = twilio.twiml.Response()
        resp.message('You have already announced your arrival.')
        ret = str(resp)

    with open(log_filename, "a") as f:
        tm = time.strftime("%Y-%m-%d %H:%M")
        log_message = '[{}] {}: {} => {}\n'.format(tm, number, message_body, result)
        f.write(log_message)

    return ret

if __name__ == "__main__":
    app.run(host='0.0.0.0')
