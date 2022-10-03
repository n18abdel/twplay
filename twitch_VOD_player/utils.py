import re
import signal
import threading
from types import FrameType
from typing import Callable, List, Optional

from pika.adapters.blocking_connection import BlockingChannel, BlockingConnection

import controller
import topics
from mpv_player import Player


def setup_exit_handler(callback: Callable[[], None]) -> None:
    def handler(signum: int, frame: Optional[FrameType]) -> None:
        callback()

    signal.signal(signal.SIGINT, handler)


def parse_vod_id(url_or_user: str) -> str:
    match = re.search(r"twitch.tv/videos/(\d+)", url_or_user)
    if match:
        return match.group(1)
    user_id = controller.retrieve_user_id(url_or_user)
    if user_id:
        return controller.retrieve_last_vod_id(user_id)
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


def get_media(local_file: Optional[str], cast: bool, vod_id: str, tmpdir: str):
    return (
        local_file
        if local_file and not cast
        else f"http://{controller.retrieve_local_ip()}:5000/{local_file}"
        if local_file and cast
        else controller.retrieve_playable_url(vod_id, tmpdir)
    )


def exit_callback(
    connections: List[BlockingConnection],
    channel: BlockingChannel,
    timer: threading.Timer,
    player: Player,
) -> None:
    print("Exiting")
    timer.cancel()
    topics.chatExit(channel)
    print("Sent exit message to chat")
    for connection in connections:
        connection.close()
    print("Closed AMQP connections")
    player.terminate()
    print("Closed player")
