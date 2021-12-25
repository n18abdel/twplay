from typing import Union

import pika
from pika.adapters.blocking_connection import BlockingChannel


def init() -> pika.BlockingConnection:
    connection = pika.BlockingConnection(pika.ConnectionParameters(host="localhost"))
    return connection


def new_channel(connection: pika.BlockingConnection) -> BlockingChannel:
    channel = connection.channel()
    channel.exchange_declare(exchange="topic_chat", exchange_type="topic")
    return channel


def publish(
    channel: BlockingChannel, routing_key: str, body: Union[str, bytes]
) -> None:
    channel.basic_publish(
        exchange="topic_chat",
        routing_key=routing_key,
        body=body,  # type: ignore[arg-type]
    )
