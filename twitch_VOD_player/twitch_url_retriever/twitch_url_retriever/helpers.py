import re
from typing import Match, Optional

import pexpect


def is_twitchtracker(url: str) -> Optional[Match[str]]:
    return re.search("twitchtracker", url)


def input_twitchtracker(child: pexpect.spawn, url: str) -> None:
    child.expect_exact(
        "Please enter the number of the option you want to select (number between 1-17 inclusive): "
    )
    child.sendline("5")
    child.expect_exact(
        "Please enter the number of the option you want to select (number between 1-2 inclusive): "
    )
    child.sendline("1")
    child.expect_exact(
        "Please enter the stream analytics link (supports Twitch Tracker and Stream Charts): "
    )
    child.sendline(url)


def input_highlight_link(child: pexpect.spawn, url: str) -> None:
    child.expect_exact(
        "Please enter the number of the option you want to select (number between 1-17 inclusive): "
    )
    child.sendline("6")
    child.expect_exact("Please enter the link of the highlight to retrieve: ")
    child.sendline(url)


def input_VOD_link(child: pexpect.spawn, url: str) -> None:
    child.expect_exact(
        "Please enter the number of the option you want to select (number between 1-17 inclusive): "
    )
    child.sendline("3")
    child.expect_exact("Please enter the link of the VOD to retrieve: ")
    child.sendline(url)


def select_source_quality(child: pexpect.spawn) -> None:
    child.expect("Please enter the desired quality you want to .*: ")
    source_quality = re.search(r"(\d)\. source", child.before.lower()).group(1)
    child.sendline(source_quality)


def parse_m3u_link(child: pexpect.spawn) -> str:
    child.expect("Do you want to .* another .*\?\s*Enter y for yes and n for no: ")
    m3u_link = re.search(r"https://.*\.m3u8", child.before).group(0)
    child.sendline("n")
    return m3u_link


def get_m3u_link(child: pexpect.spawn, url: str, highlight: str) -> str:
    if is_twitchtracker(url):
        input_twitchtracker(child, url)
    elif highlight:
        input_highlight_link(child, url)
    else:
        input_VOD_link(child, url)
    select_source_quality(child)
    m3u_link = parse_m3u_link(child)
    return m3u_link


def perform_new_operation(child: pexpect.spawn) -> None:
    child.expect(
        "Do you want to continue using the program/perform a new operation\?\s*Please enter 'y' for yes and 'n' for no: "
    )
    child.sendline("y")


def check_muted_segments(child: pexpect.spawn, m3u_link: str) -> bool:
    child.expect_exact(
        "Please enter the number of the option you want to select (number between 1-17 inclusive): "
    )
    child.sendline("9")
    child.expect_exact("Please enter the link of the M3U8 to check: ")
    child.sendline(m3u_link)
    child.expect(
        "Do you want to check another video\?\s*Enter y for yes and n for no: "
    )
    muted_segments = not re.search("does not", child.before.lower())
    child.sendline("n")
    return muted_segments


def unmute(child: pexpect.spawn, m3u_link: str, tmpdir: str) -> str:
    child.expect_exact(
        "Please enter the number of the option you want to select (number between 1-17 inclusive): "
    )
    child.sendline("10")
    child.expect_exact(
        "Please enter the number of the option you want to select (number between 1-2 inclusive): "
    )
    child.sendline("1")
    child.expect_exact("Please input the URL of the M3U8 to unmute: ")
    child.sendline(m3u_link)
    child.expect_exact("File path: ")
    child.sendline(tmpdir)
    child.expect(
        "Do you want to unmute another video\?\s*Enter y for yes and n for no: "
    )
    filepath = re.search(r"file at: (.*\.m3u8)", child.before).group(1)
    return filepath
