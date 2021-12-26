from typing import Tuple, Union

import pika
from pika.adapters.blocking_connection import BlockingChannel


def init() -> Tuple[pika.BlockingConnection, BlockingChannel]:
    connection = pika.BlockingConnection(pika.ConnectionParameters(host="localhost"))
    channel = connection.channel()
    channel.exchange_declare(exchange="topic_chat", exchange_type="topic")
    return connection, channel


def publish(
    channel: BlockingChannel, routing_key: str, body: Union[str, bytes]
) -> None:
    channel.basic_publish(
        exchange="topic_chat",
        routing_key=routing_key,
        body=body,  # type: ignore[arg-type]
    )
