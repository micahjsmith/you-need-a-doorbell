from flask import Flask, request, redirect
import twilio.twiml
import subprocess
import time
import configparser
import tempfile
import os
from shutil import which

app = Flask(__name__)

sms_path = "/party_arrival"
DEFAULT_CONFIG_FILE_LOCATION = os.path.join(
        os.path.expanduser("~"),".partyapp.conf")

# Settings
c = None
lists = {}
lists["hostlist"]  = {}
lists["whitelist"] = {}
lists["blacklist"] = {}
lists["arrivals"]  = {}

def load_config():
    config = configparser.ConfigParser()
    config.read_file(open("defaults.conf"))
    config.read([DEFAULT_CONFIG_FILE_LOCATION])

    # copy hostlist, whitelist, and blacklist
    for l in ["hostlist", "whitelist", "blacklist"]:
        lists[l] = dict(config[l])

    return dict(config["app"])

def validate_config(c):
    # Ensure that arrival_message has at most one '{}'
    if c["arrival_message"].count("{}") > 1:
        raise ValueError("arrival_message must contain at most one '{}'")

    # Ensure that tts prog ram exists
    if which(c["tts_command"]) is None:
        raise EnvironmentError("unable to verify that tts command {} is callable".format(c["tts_command"]))

    # Ensure log file directory exists
    if c["log_file"] == "":
        d = tempfile.mkdtemp()
        f = os.path.join(d, "party_arrivals.log")
        c["log_file"] = f
    else:
        d = os.path.dirname(c["log_file"])
        if not os.path.exists(d):
            os.makedirs(d)

    print('Logging to {}'.format(c["log_file"]))

    return True
>>>>>>> Move options to a conf file, refactoring

@app.route("/", methods=['GET'])
def hello():
    return "Hello World"

def log(sms_number, sms_name, result):
    with open(c["log_file"], "a") as f:
        tm = time.strftime("%Y-%m-%d %H:%M")
        log_message = '[{}] {}: {} => {}\n'.format(
                tm, sms_number, sms_name, result)
        f.write(log_message)

def announce(person):
    message = c["doorbell_text"] + " " + c["arrival_message"].format(person)
    subprocess.call([c["tts_command"], c["tts_command_options"], message])

def reply(message):
    resp = twilio.twiml.Response()
    resp.message(message)
    return str(resp)

@app.route(sms_path, methods=['POST'])
def party_arrival():
    sms_number = request.form['From']
    sms_name = request.form['Body']

    is_host = sms_number in lists["hostlist"].values()
    is_approved = (sms_number in lists["whitelist"].values() or
        (not any(lists["whitelist"]) and sms_number not in lists["blacklist"].values()))
    has_arrived = sms_number in lists["arrivals"].values()

    if is_host or (is_approved and not has_arrived):
        result = "announced"

        # Add to list of arrivals
        lists["arrivals"][sms_name] = sms_number

        # Announce
        announce(sms_name)

        # Text back
        ret = reply(c["arrival_response"])
    elif is_approved and has_arrived:
        result = "repeat"

        # Text back
        ret = reply(c["repeat_response"])
    elif not is_approved:
        result = "rejected"
        ret = ""
    else:
        result = "other"
        ret = ""

    # Log the result
    log(sms_number, sms_name, result)

    return ret

if __name__ == "__main__":
    c = load_config()
    validate_config(c)
    app.run(host=c["host"], port=c["port"])
