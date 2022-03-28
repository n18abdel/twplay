import json
import subprocess
import tempfile
from time import sleep
from typing import Optional, Union

import requests


def fetch_chat(
    vod_id: str,
    chat_file: Optional[str],
    beginning: Optional[str],
    ending: Optional[str],
) -> bytes:
    if chat_file:
        with open(chat_file, "r") as f:
            chat = f.readline()
    else:
        with tempfile.NamedTemporaryFile() as f:
            command = [
                "TwitchDownloaderCLI",
                "-m",
                "ChatDownload",
                "--id",
                vod_id,
                "-o",
                f.name,
            ]
            if beginning:
                command.extend(["-b", beginning])
            if ending:
                command.extend(["-e", ending])
            subprocess.run(command)
            chat = f.readline()
    return chat


def retrieve_playable_url(vod_id: Union[int, str], tmpdir: str) -> str:
    with tempfile.NamedTemporaryFile() as f:
        subprocess.run(
            [
                "twitch_url_retriever",
                f"https://www.twitch.tv/videos/{vod_id}",
                "-o",
                f.name,
                "--tmpdir",
                tmpdir,
            ]
        )
        url = f.readline().decode("utf-8")
    return url


def launch_chat_renderer() -> None:
    subprocess.run(["open", "-a", "twitch_chat_render"])


def is_docker_running() -> bool:
    return subprocess.run(["docker", "ps"]).returncode == 0


def launch_docker() -> None:
    while not is_docker_running():
        subprocess.run(["open", "-a", "Docker"])
        sleep(20)


def is_rabbitmq_running() -> bool:
    try:
        r = requests.get("http://localhost:15672")
    except Exception:
        return False
    else:
        return r.ok


def launch_rabbitmq() -> None:
    launch_docker()
    while not is_rabbitmq_running():
        subprocess.run(
            [
                "docker",
                "run",
                "-d",
                "--rm",
                "-p",
                "15672:15672",
                "-p",
                "5672:5672",
                "telecom/rabbitmq",
            ]
        )
        sleep(20)


def retrieve_user_id(username: str) -> Optional[str]:
    p = subprocess.run(
        ["twitch", "api", "get", "users", "-q", f"login={username}"],
        capture_output=True,
    )
    output = json.loads(p.stdout)["data"]
    if len(output) > 0:
        return str(output[0]["id"])
    return None


def retrieve_last_vod_id(user_id: str) -> str:
    p = subprocess.run(
        ["twitch", "api", "get", "videos", "-q", f"user_id={user_id}"],
        capture_output=True,
    )
    return str(json.loads(p.stdout)["data"][0]["id"])
