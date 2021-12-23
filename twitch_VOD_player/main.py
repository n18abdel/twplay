from python_mpv_jsonipc import MPV

# Uses MPV that is in the PATH.
# mpv = MPV()

import pika

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
connection.close()

# mpv.play("https://www.twitch.tv/videos/1235109843")
