import argparse
import sys

import pexpect

import helpers

kwargs = {"encoding": "utf-8", "logfile": sys.stdout}


def main() -> None:
    parser = argparse.ArgumentParser(description="Retrive a VOD m3u8")
    parser.add_argument("url", help="a Twitch VOD/highlight or TwitchTracker link")
    parser.add_argument(
        "-o", "--output", help="file to write the URL or path of the saved m3u8"
    )
    parser.add_argument("--tmpdir", default=".", help="location to save m3u8 if needed")
    parser.add_argument(
        "--highlight", action="store_true", help="if highlight instead of VOD"
    )
    args = parser.parse_args()

    child = pexpect.spawn("twrec", **kwargs)
    m3u_link = helpers.get_m3u_link(child, args.url, args.highlight)
    helpers.perform_new_operation(child)
    muted_segments = helpers.check_muted_segments(child, m3u_link)
    helpers.perform_new_operation(child)
    if muted_segments:
        filepath = helpers.unmute(child, m3u_link, args.tmpdir)
        path = filepath
    else:
        path = m3u_link
    child.close()
    if args.output:
        with open(args.output, "w") as f:
            f.writelines([path])


if __name__ == "__main__":
    main()
