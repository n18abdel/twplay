import argparse
import tempfile
from functools import partial

import amqp
import controller
import topics
import utils
from chromecast_player import ChromecastPlayer
from mpv_player import MpvPlayer

UPDATE_PERIOD = 60


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Play a Twitch VOD with the chat using MPV and a chat renderer"
    )
    parser.add_argument(
        "url_or_user",
        help="a Twitch VOD url or a Twitch username",
        nargs="?",
        default="papesan",
    )
    parser.add_argument("-f", "--local_file", help="a local file of the VOD")
    parser.add_argument("-c", "--chat_file", help="a local chat file of the VOD")
    parser.add_argument(
        "-b",
        "--beginning",
        help="""
        Time in seconds to crop beginning.
        For example,
        if I wanted a 10 second stream but only wanted the last 7 seconds of it,
        I would use -b 3 to skip the first 3 seconds of it.
        """,
    )
    parser.add_argument(
        "-e",
        "--ending",
        help="""
        Time in seconds to crop ending.
        For example,
        if I wanted a 10 second stream but only wanted the first 4 seconds of it,
        I would use -e 4 remove the last 6 seconds of it.
        """,
    )
    parser.add_argument(
        "-ca",
        "--cast",
        action="store_true",
        help="cast to shield tv",
    )
    args = parser.parse_args()

    controller.launch_rabbitmq()
    controller.launch_chat_renderer()

    vod_id = utils.parse_vod_id(args.url_or_user)
    chat = controller.fetch_chat(vod_id, args.chat_file, args.beginning, args.ending)

    connections = amqp.init(8)

    controller.send_chat_file(amqp.new_channel(connections[0]), chat)

    player = ChromecastPlayer() if args.cast else MpvPlayer()

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
    utils.setup_keyboard_controls_handler(player)
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
    media = utils.get_media(
        args.local_file, args.cast, args.url_or_user, vod_id, tmpdir
    )
    player.play(media)


if __name__ == "__main__":
    main()
