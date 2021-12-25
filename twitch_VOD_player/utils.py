import re
import signal
import subprocess
import tempfile
import threading

import topics
from player import Player


def setup_exit_handler(callback):
    def handler(signum, frame):
        callback()
        exit(0)

    signal.signal(signal.SIGINT, handler)


def parse_vod_id(args):
    return re.search(r"twitch.tv/videos/(\d+)", args.url).group(1)


def download_chat(vod_id):
    with tempfile.NamedTemporaryFile() as f:
        subprocess.run(
            ["TwitchDownloaderCLI", "-m", "ChatDownload", "--id", vod_id, "-o", f.name]
        )
        chat = f.readline()
    return chat


def send_chat_file(channel, chat):
    topics.json(channel, chat)


def setup_timer_loop(player: Player, channel, period):
    def timer_callback():
        if player.current_pos():
            topics.timer(channel, player.current_pos())

    t = threading.Timer(period, timer_callback)
    t.start()
    return t


def exit_callback(connection, channel, player: Player, timer):
    print("Exiting")
    timer.cancel()
    topics.chatExit(channel)
    print("Sent exit message to chat")
    connection.close()
    print("Closed AMQP connection")
    player.terminate()
    print("Closed MPV")
