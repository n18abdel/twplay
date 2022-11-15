import re
import signal
import threading
from functools import partial
from types import FrameType
from typing import Callable, List, Optional, Union

from pika.adapters.blocking_connection import BlockingChannel, BlockingConnection
from pynput import keyboard

import controller
import topics
from mpv_player import MpvPlayer
from player import Player


def setup_exit_handler(callback: Callable[[], None]) -> None:
    def handler(signum: int, frame: Optional[FrameType]) -> None:
        callback()

    signal.signal(signal.SIGINT, handler)


def parse_vod_id(url_or_user: str) -> str:
    is_twitch_vod_link = re.search(r"twitch.tv/videos/(\d+)", url_or_user)
    is_twitchtracker_link = re.search(
        r"twitchtracker.com/.*/streams/(\d+)", url_or_user
    )
    if is_twitch_vod_link:
        return is_twitch_vod_link.group(1)
    user_id = controller.retrieve_user_id(url_or_user)
    if user_id:
        return controller.retrieve_last_vod_id(user_id)
    elif is_twitchtracker_link:
        return None
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


class RepeatTimer(threading.Timer):
    def run(self):
        while not self.finished.wait(self.interval):
            self.function(*self.args, **self.kwargs)


def setup_timer_loop(
    player: Player, channel: BlockingChannel, period: int
) -> RepeatTimer:
    def timer_callback() -> None:
        if player.current_pos:
            topics.timer(channel, str(player.current_pos))

    t = RepeatTimer(period, timer_callback)
    t.start()
    return t


def get_media(
    local_file: Optional[str],
    cast: bool,
    url_or_user: str,
    vod_id: Optional[str],
    tmpdir: str,
):
    resolved = local_file or controller.retrieve_playable_url(
        url_or_user, vod_id, tmpdir
    )
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


def on_press(player: Player, key: Union["keyboard.Key", "keyboard.KeyCode", None]):
    if key == keyboard.Key.up:
        player.speed_up()
    if key == keyboard.Key.down:
        player.slow_down()
    if key == keyboard.Key.left:
        player.backward()
    if key == keyboard.Key.right:
        player.forward()
    if key == keyboard.Key.space:
        player.toggle_play()
    if key == keyboard.KeyCode.from_char("k"):
        position = input("Please input the desired seeking position: ")
        if position != "":
            player.seek(position)


def setup_keyboard_controls_handler(player: Player):
    if not isinstance(player, MpvPlayer):
        listener = keyboard.Listener(on_press=partial(on_press, player))
        listener.start()


def exit_callback(
    connections: List[BlockingConnection],
    channel: BlockingChannel,
    timer: RepeatTimer,
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
