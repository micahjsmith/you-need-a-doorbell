# you-need-a-doorbell

If you need a doorbell, you're in the right place. Digitally retrofit your decrepit
apartment building or dorm with this handy app.

Features
- Easily configure a party-specific phone number using Twilio, avoiding giving out your
    number to annoying people you didn't invite who might text you after
- Super loud and annoying announcements so the entire party knows someone has arrived
- Configure multiple hosts with admin privileges, or whitelists and blacklists of guests
- Avoid spam

For now, this app runs locally on your macOS computer. (It uses the macOS `say` utility by
default, though you may also be able to use another system that has a text-to-speech utility
like `espeak`.) It would be nice to host this in the cloud and allow the party hosts to log
in via a web interface, which I might get to in the future as my web programming improves.

## Setup

You should have `python3` and `pip3` installed.

Download the code
```
git clone https://github.com/micahjsmith/you-need-a-doorbell.git
```

Install requirements
```
cd you-need-a-doorbell
pip3 install -r requirements.txt
```

Create a custom config file
```
cp defaults.conf ~/.ynad.conf
```

Edit your custom config file as you see fit. Values in your config file will override the
default values. See [configuration](#configuration).

### Set up Twilio

Sign up for Twilio [here](https://www.twilio.com/try-twilio). You can use a trial account
for free; note that in this case, outgoing messages are restricted to phone numbers you can
verify that you own.

In the Twilio console, select the *Phone Numbers* tab, then register a new phone number
under *Manage Numbers*.

Determine the URL to be associated with a party arrival and add it to Twilio
- get your public DNS address, which you should be able to do using `hostname`. The
    correctness of this approach may vary by system and networking setup.

    ```
    $ hostname
    my-ip-1-2-3-4.me.com
    ```
- get your app port, from your config file
- get your sms path, from your config file
- create the URL `http://my-ip-1-2-3-4.me.com:5000/party_arrival`
- In your Twilio console, click on the number you registered. On the *Configure* tab, scroll
    down to *Messaging*. Fill in the field for "A Message Comes In" with the URL above, and
    select the "Webhook" and "HTTP POST" settings. Save your changes.

### Start the party!

Run the app
```
$ python3 app.py
```

A nice log file will be written to. The path to the log file is printed to the console. View
this output with a command like `tail -f /path/to/log/file.log` in another console.

Connect your speakers and turn the volume up!

By the way, make sure to actually invite people to your party and tell them how to use your
*you-need-a-doorbell* system. Example text:
> In [your horrible apartment], its a bit tricky to let people in as there is no doorbell
> and someone has to walk to the door. As such, I'm using "you-need-a-doorbell", a
> sophisticated digital doorbell system. Arrive to [your address]. Then, send a message to
> [your party's number] and include your name as the only text. An announcement will be made
> inside the party and someone will come open the door for you. Warning- you can only
> announce your arrival once, so don't text until you're actually at the door.

## Configuration

There are a variety of general configuration options under the `app` section.
- `port`: Flask serves your app on this port.
- `host`: Flask serves your app at this host; use `0.0.0.0` to expose the app to the
    internet. You can use `localhost` for local debugging, though you will have to
    craft the POST requests corresponding to text messages by hand.
- `sms_path`: The relative URL that Twilio should POST to when a text arrives. (Start
    with `/`.)
- `log_file`: Path for the log file. If left blank, a file will be created in a
    temporary directory.
- `tts_command`: Text-to-speech executable on your system. `say` is a nice choice on
    macOS.
- `tts_command_options`: Additional options to pass to the text-to-speech command. For
    example, try `-v Moira` for an Irish-American voice.
- `doorbell_text`: Whatever a doorbell spells like, you precious flower.
- `arrival_message`: After the doorbell text is played, this message is spoken to
    announce the guest to the party. The literal `{}` will be replaced with the guest's
    self-identification, as written in the body of their text message. The `{}` can be
    safely omitted if you want to be surprised!
- `arrival_response`: Your app's response text message to the guest. You can let them
    know that someone is coming, or give them more detailed instructions. (*Make sure you
    are standing on Mulberry Street under the green awning.*)
- `repeat_response`: Your app's response text message to a *repeat* text from the guest.
    That is, their arrival is announced only once to avoid spam. This message is sent to
    them if they try to text more than once.

You can add to the host list, whitelist, and blacklist. A sensible configuration is to leave
both the whitelist and the blacklist blank.
- Guests in the hostlist have "admin" privileges, which currently consists of being able to
    have their texts announced without limit, so they can show off to their friends and loved ones.
- Guests in the whitelist are explicitly invited and their texts to the
    *you-need-a-doorbell* number will be processed. If this section has no entries, then any
    phone number that is not listed in the blacklist is allowed. If there are any entries in
    the whitelist, then the blacklist will be ignored completely, even if it has entries.
- Guests in the blacklist are not invited to the party and all of their texts to the
    *you-need-a-doorbell* number will be ignored. If this section has no entries, then there
    are no specific numbers that are blocked.

Entries in each of these lists should have the form
```
Flo Rida = +13055282786
```
Note that the `+1` country code is necessary to identify US phone numbers. If you are in a
different country, substitute your own country code.

## Troubleshooting

- Ensure that your network settings are configured correctly by pointing your browser to
`http://my-ip-1-2-3-4.me.com:5000/`. You should see a "Hello World" page.
- If you don't hear anything but things seem to otherwise be working (log file looks okay,
    etc.), try to issue a `say` command from the command line. On my computer, `say` hangs
    on terminals inside a tmux session and the app needs to be run from its own terminal
    window.
- Check the log for your phone number in the Twilio console to make sure that messages are
    being received and sent correctly.
- Please let me know if you find any bugs.
