import argparse
import sys
import tempfile

import pexpect

import helpers

kwargs = {"encoding": "utf-8", "logfile": sys.stdout}


def main() -> None:
    parser = argparse.ArgumentParser(description="Play a Twitch VOD")
    parser.add_argument("url", help="a Twitch VOD/highlight or TwitchTracker link")
    parser.add_argument("-o", "--output", help="output file")
    parser.add_argument(
        "--highlight", action="store_true", help="if highlight instead of VOD"
    )
    args = parser.parse_args()

    child = pexpect.spawn("twrec", **kwargs)
    m3u_link = helpers.get_m3u_link(child, args.url, args.highlight)
    helpers.perform_new_operation(child)
    muted_segments = helpers.check_muted_segments(child, m3u_link)
    helpers.perform_new_operation(child)
    with tempfile.TemporaryDirectory() as tmpdir:
        if muted_segments:
            filepath = helpers.unmute(child, m3u_link, tmpdir)
            path = filepath
        else:
            path = m3u_link
        child.close()
        with open(args.output, "w") as f:
            f.writelines([path])


if __name__ == "__main__":
    main()
