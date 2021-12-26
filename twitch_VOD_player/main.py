import argparse
from functools import partial

import amqp
import topics
import utils
from player import Player

UPDATE_PERIOD = 60

parser = argparse.ArgumentParser(
    description="Play a Twitch VOD with the chat using MPV and a chat renderer"
)
parser.add_argument("url", help="a Twitch VOD url")
args = parser.parse_args()

vod_id = utils.parse_vod_id(args.url)
chat = utils.download_chat(vod_id)

connection, channel = amqp.init()

utils.send_chat_file(channel, chat)

player = Player()

timer = utils.setup_timer_loop(player, channel, period=UPDATE_PERIOD)

player.on_seek(partial(topics.seek, channel))
player.on_play(partial(topics.play, channel))
player.on_pause(partial(topics.pause, channel))
player.on_speed_change(partial(topics.speed, channel))
player.on_end_of_file(partial(utils.exit_callback, connection, channel, timer))

utils.setup_exit_handler(
    partial(
        utils.exit_callback,
        connection,
        channel,
        timer,
        player,
    )
)

player.play(f"https://www.twitch.tv/videos/{vod_id}")
