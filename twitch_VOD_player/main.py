import argparse
import tempfile
from functools import partial

import amqp
import controller
import topics
import utils
from player import Player

UPDATE_PERIOD = 60


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Play a Twitch VOD with the chat using MPV and a chat renderer"
    )
    parser.add_argument("url_or_user", help="a Twitch VOD url or a Twitch username")
    parser.add_argument("-f", "--local_file", help="a local file of the VOD")
    args = parser.parse_args()

    controller.launch_rabbitmq()
    controller.launch_chat_renderer()

    vod_id = utils.parse_vod_id(args.url_or_user)
    chat = controller.download_chat(vod_id)

    connections = amqp.init(8)

    utils.send_chat_file(amqp.new_channel(connections[0]), chat)

    player = Player()

    timer = utils.setup_timer_loop(
        player, amqp.new_channel(connections[1]), period=UPDATE_PERIOD
    )

    player.on_seek(partial(topics.seek, amqp.new_channel(connections[2])))
    player.on_play(partial(topics.play, amqp.new_channel(connections[3])))
    player.on_pause(partial(topics.pause, amqp.new_channel(connections[4])))
    player.on_speed_change(partial(topics.speed, amqp.new_channel(connections[5])))
    player.on_end_of_file(
        partial(
            utils.exit_callback, connections, amqp.new_channel(connections[6]), timer
        )
    )

    utils.setup_exit_handler(
        partial(
            utils.exit_callback,
            connections,
            amqp.new_channel(connections[7]),
            timer,
            player,
        )
    )

    tmpdir = tempfile.mkdtemp()
    player.play(
        args.local_file
        if args.local_file
        else controller.retrieve_playable_url(vod_id, tmpdir)
    )


if __name__ == "__main__":
    main()
