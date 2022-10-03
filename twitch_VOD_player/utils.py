import re
import signal
import threading
from functools import partial
from types import FrameType
from typing import Callable, List, Optional

from pika.adapters.blocking_connection import BlockingChannel, BlockingConnection
from pynput import keyboard

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
    resolved = local_file or controller.retrieve_playable_url(vod_id, tmpdir)
    if cast:
        controller.launch_file_server(resolved)
        local_ip = controller.retrieve_local_ip()
        return (
            f"http://{local_ip}:5000/{local_file}"
            if local_file
            else f"http://{local_ip}:5000/playlist.m3u8"
        )
    else:
        return resolved


def on_press(player: Player, key: keyboard.Key):
    if key == keyboard.Key.up:
        current_speed = player.get_speed()
        if current_speed < 1:
            player.set_speed(1)
        elif current_speed < 1.5:
            player.set_speed(1.5)
        elif current_speed < 2:
            player.set_speed(2)
    if key == keyboard.Key.down:
        current_speed = player.get_speed()
        if current_speed > 1.5:
            player.set_speed(1.5)
        elif current_speed > 1:
            player.set_speed(1)
        elif current_speed > 0.5:
            player.set_speed(0.5)


def setup_speed_handler(player: Player):
    listener = keyboard.Listener(on_press=partial(on_press, player))
    listener.start()


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
