import subprocess
import tempfile
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
