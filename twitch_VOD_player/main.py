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


vod_id = utils.parse_vod_id(args)
chat = utils.download_chat(vod_id)

connection = amqp.init()

utils.send_chat_file(amqp.new_channel(connection), chat)

player = Player()
player.on_seek(partial(topics.seek, amqp.new_channel(connection)))
player.on_play(partial(topics.play, amqp.new_channel(connection)))
player.on_pause(partial(topics.pause, amqp.new_channel(connection)))
player.on_end_of_file(
    partial(utils.exit_callback, connection, amqp.new_channel(connection))
)

player.play(f"https://www.twitch.tv/videos/{vod_id}")


timer = utils.setup_timer_loop(
    player, amqp.new_channel(connection), period=UPDATE_PERIOD
)

utils.setup_exit_handler(
    partial(
        utils.exit_callback, connection, amqp.new_channel(connection), player, timer
    )
)
