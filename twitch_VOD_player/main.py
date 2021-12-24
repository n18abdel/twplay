import argparse
from functools import partial

from amqp import init_amqp
from player import Player
from topics import pause, play, seek
from utils import (
    download_chat,
    exit_callback,
    parse_vod_id,
    send_chat_file,
    setup_exit_handler,
    timer_loop,
)

UPDATE_PERIOD = 60

parser = argparse.ArgumentParser(
    description="Play a Twitch VOD with the chat using MPV and a chat renderer"
)
parser.add_argument("url", help="a Twitch VOD url")
args = parser.parse_args()


vod_id = parse_vod_id(args)
chat = download_chat(vod_id)

connection, channel = init_amqp(chat)

send_chat_file(channel, chat)

player = Player()
player.on_seek(partial(seek, channel))
player.on_play(partial(play, channel))
player.on_pause(partial(pause, channel))
player.on_end_of_file(partial(exit_callback, connection, channel))

player.play(f"https://www.twitch.tv/videos/{vod_id}")

setup_exit_handler(partial(exit_callback, connection, channel, player))

timer_loop(player, channel, period=UPDATE_PERIOD)
