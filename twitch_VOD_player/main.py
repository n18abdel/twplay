import pika
from python_mpv_jsonipc import MPV
import time

# Uses MPV that is in the PATH.
mpv = MPV()


connection = pika.BlockingConnection(pika.ConnectionParameters(
    host='localhost'))
channel = connection.channel()

channel.exchange_declare(exchange='topic_chat',
                         exchange_type='topic')
with open("chat.json", "r") as f:
    chat = f.readline()

channel.basic_publish(exchange='topic_chat',
                      routing_key='json',
                      body=chat)


@mpv.on_event("file-loaded")
def on_loading(event_data):
    mpv.pause = "yes"


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
    connection.close()
    mpv.terminate()


mpv.play("https://www.twitch.tv/videos/1235109843")

t0 = time.time()
while mpv.mpv_process.process.poll() is None:
    t1 = time.time()
    if (t1-t0) >= 60.0:
        t0 = t1
        if mpv.time_pos:
            channel.basic_publish(exchange='topic_chat',
                                  routing_key='sync.timer',
                                  body=str(mpv.time_pos))
