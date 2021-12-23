from python_mpv_jsonipc import MPV

# Uses MPV that is in the PATH.
mpv = MPV()

import pika

connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
channel = connection.channel()

channel.exchange_declare(exchange='chat',
                         exchange_type='fanout')
with open("chat.json", "r") as f:
        chat = f.readline()

channel.basic_publish(exchange='chat',
                      routing_key='',
                      body=chat)
print(f" [x] Sent chat file of length {len(chat)}")
connection.close()

mpv.play("https://www.twitch.tv/videos/1235109843")
