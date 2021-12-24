import re
import signal
import subprocess
import tempfile
import time

from player import Player
from topics import chatExit, json, timer


def setup_exit_handler(callback):
    def handler(signum, frame):
        callback()
        exit(0)

    signal.signal(signal.SIGINT, handler)


def parse_vod_id(args):
    return re.search("twitch.tv/videos/(\d+)", args.url).group(1)


def download_chat(vod_id):
    with tempfile.NamedTemporaryFile() as f:
        subprocess.run(
            ["TwitchDownloaderCLI", "-m", "ChatDownload", "--id", vod_id, "-o", f.name]
        )
        chat = f.readline()
    return chat


def send_chat_file(channel, chat):
    json(channel, chat)


def timer_loop(player: Player, channel, period):
    t0 = time.time()
    while player.is_running():
        t1 = time.time()
        if (t1 - t0) >= period:
            t0 = t1
            if player.current_pos():
                timer(channel, player.current_pos())


def exit_callback(connection, channel, player: Player):
    print("Exiting")
    chatExit(channel)
    print("Sent exit message to chat")
    connection.close()
    print("Closed AMQP connection")
    player.terminate()
    print("Closed MPV")
