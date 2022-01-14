import subprocess
import tempfile
from time import sleep
from typing import Union


def download_chat(vod_id: str) -> bytes:
    with tempfile.NamedTemporaryFile() as f:
        subprocess.run(
            ["TwitchDownloaderCLI", "-m", "ChatDownload", "--id", vod_id, "-o", f.name]
        )
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
    return "rabbitmq" in subprocess.check_output(["docker", "ps"], encoding="utf-8")


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
