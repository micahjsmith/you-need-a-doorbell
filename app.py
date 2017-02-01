from flask import Flask, request, redirect
import twilio.twiml
import subprocess
import time
import configparser
import tempfile
import os
import random
from shutil import which

app = Flask(__name__)

sms_path = "/party_arrival"
DEFAULT_CONFIG_FILE_LOCATION = os.path.join(
        os.path.expanduser("~"),".ynad.conf")

# Settings
c     = None
lists = {}
lists["hostlist"]  = {}
lists["whitelist"] = {}
lists["blacklist"] = {}
lists["arrivals"]  = []

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

def log(sms_number, sms_name, result, door_assignment):
    with open(c["log_file"], "a") as f:
        tm = time.strftime("%Y-%m-%d %H:%M")
        log_message = '[{}] {}: {} => {}'.format(
                tm, sms_number, sms_name, result)
        f.write(log_message)
        if door_assignment is not None:
            person = door_assignment[0]
            last_four = door_assignment[1][-4:]
            f.write(" (assigned {} {})".format(person, last_four))
        f.write("\n")

def announce(person):
    message = c["doorbell_text"] + " " + c["arrival_message"].format(person)
    subprocess.call([c["tts_command"], c["tts_command_options"], message])

# Randomly assign an arrived guest to open the door. It's okay to not do any
# validation for duplicate messages as we allow the host to do "testing" and
# non-hosts can only announce once anyway. One unaddressed problem is that
# multiple guests can have the same name.
def assign():
    if c["random_assignment"] in ["y","Y","yes","Yes","1","true","True"]:
        num_arrivals = len(lists["arrivals"])
        if num_arrivals > 0:
            r = random.randint(0,num_arrivals-1)
            a = lists["arrivals"][r]
            person = a[0]
            message = c["assignment_message"].format(person)
            subprocess.call([c["tts_command"], c["tts_command_options"], message])
            return a
    else:
        return None

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
    has_arrived = sms_number in [a[0] for a in lists["arrivals"]]

    if is_host or (is_approved and not has_arrived):
        result = "announced"

        # Announce
        announce(sms_name)

        # Assign - only called if config dictates
        door_assignment = assign()

        # Add to list of arrivals. Do this *after* door assignment so we don't
        # assign the person who has arrived!
        lists["arrivals"].append((sms_name,sms_number))

        # Text back
        ret = reply(c["arrival_response"])
    elif is_approved and has_arrived:
        result = "repeat"
        door_assignment = None
        ret = reply(c["repeat_response"])
    elif not is_approved:
        result = "rejected"
        door_assignment = None
        ret = ""
    else:
        result = "other"
        door_assignment = None
        ret = ""

    # Log the result
    log(sms_number, sms_name, result, door_assignment)

    return ret

if __name__ == "__main__":
    c = load_config()
    validate_config(c)
    app.run(host=c["host"], port=c["port"])
