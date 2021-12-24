import pika
from python_mpv_jsonipc import MPV
import time
import signal
import argparse
import re
import subprocess
import tempfile

UPDATE_PERIOD = 60

parser = argparse.ArgumentParser(
    description='Play a Twitch VOD with the chat using MPV and a chat renderer')
parser.add_argument(
    'url', help='a Twitch VOD url')
args = parser.parse_args()

vod_id = re.search("twitch.tv/videos/(\d+)", args.url).group(1)

with tempfile.NamedTemporaryFile() as f:
    subprocess.run(["TwitchDownloaderCLI", "-m",
                    "ChatDownload", "--id", vod_id, "-o", f.name])
    chat = f.readline()

# Uses MPV that is in the PATH.
mpv = MPV()


connection = pika.BlockingConnection(pika.ConnectionParameters(
    host='localhost'))
channel = connection.channel()

channel.exchange_declare(exchange='topic_chat',
                         exchange_type='topic')

channel.basic_publish(exchange='topic_chat',
                      routing_key='json',
                      body=chat)


@mpv.on_event("file-loaded")
def on_loading(event_data):
    mpv.pause = "yes"


@mpv.on_event("seek")
def on_loading(event_data):
    if mpv.time_pos:
        channel.basic_publish(exchange='topic_chat',
                              routing_key='sync.seek',
                              body=str(mpv.time_pos))


@mpv.property_observer("pause")
def on_play_pause(property_name, new_value):
    if mpv.time_pos:
        if new_value:
            channel.basic_publish(exchange='topic_chat',
                                  routing_key='sync.pause',
                                  body=str(mpv.time_pos))
        else:
            channel.basic_publish(exchange='topic_chat',
                                  routing_key='sync.play',
                                  body=str(mpv.time_pos))


@mpv.on_event("end-file")
def on_ending(event_data):
    print("Exiting")
    channel.basic_publish(exchange='topic_chat',
                          routing_key='exit',
                          body="")
    print("Sent exit message to chat")
    connection.close()
    print("Closed AMQP connection")
    mpv.terminate()
    print("Closed MPV")


mpv.play(f"https://www.twitch.tv/videos/{vod_id}")


def handler(signum, frame):
    on_ending(None)
    exit(0)


signal.signal(signal.SIGINT, handler)

t0 = time.time()
while mpv.mpv_process.process.poll() is None:
    t1 = time.time()
    if (t1-t0) >= UPDATE_PERIOD:
        t0 = t1
        if mpv.time_pos:
            channel.basic_publish(exchange='topic_chat',
                                  routing_key='sync.timer',
                                  body=str(mpv.time_pos))
