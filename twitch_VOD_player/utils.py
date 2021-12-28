import re
import signal
import threading
from types import FrameType
from typing import Callable, Optional, Union

from pika.adapters.blocking_connection import BlockingChannel, BlockingConnection

import topics
from player import Player


def setup_exit_handler(callback: Callable[[], None]) -> None:
    def handler(signum: int, frame: Optional[FrameType]) -> None:
        callback()
        exit(0)

    signal.signal(signal.SIGINT, handler)


def parse_vod_id(url: str) -> str:
    match = re.search(r"twitch.tv/videos/(\d+)", url)
    if match:
        return match.group(1)
    else:
        print(
            "Couldn't parse VOD id\n",
            "The URL should have the following form:\n",
            "twitch.tv/videos/<vod_id>",
            "OR",
            "http://twitch.tv/videos/<vod_id>",
            "OR",
            "https://twitch.tv/videos/<vod_id>",
        )
        exit(1)


def send_chat_file(channel: BlockingChannel, chat: Union[str, bytes]) -> None:
    topics.json(channel, chat)


def setup_timer_loop(
    player: Player, channel: BlockingChannel, period: int
) -> threading.Timer:
    def timer_callback() -> None:
        if player.current_pos():
            topics.timer(channel, str(player.current_pos()))
        threading.Timer(period, timer_callback).start()

    t = threading.Timer(period, timer_callback)
    t.start()
    return t


def exit_callback(
    connection: BlockingConnection,
    channel: BlockingChannel,
    timer: threading.Timer,
    player: Player,
) -> None:
    print("Exiting")
    timer.cancel()
    topics.chatExit(channel)
    print("Sent exit message to chat")
    connection.close()
    print("Closed AMQP connections")
    player.terminate()
    print("Closed MPV")
