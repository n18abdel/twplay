import pika


def init(chat):
    connection = pika.BlockingConnection(pika.ConnectionParameters(host="localhost"))
    return connection


def new_channel(connection):
    channel = connection.channel()
    channel.exchange_declare(exchange="topic_chat", exchange_type="topic")
    return channel


def publish(channel, routing_key, body):
    channel.basic_publish(exchange="topic_chat", routing_key=routing_key, body=body)
