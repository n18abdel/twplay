import threading
import time
from copy import copy
from typing import Callable, Optional

import pychromecast
from pychromecast import quick_play
from pychromecast.controllers.media import MediaStatus, MediaStatusListener

# Change to the friendly name of your Chromecast
CAST_NAME = "SHIELD"
APP_NAME = "default_media_receiver"


class MyMediaStatusListener(MediaStatusListener):
    """Status media listener"""

    def __init__(self, name: str):
        self.name = name
        self._old_status = None
        self._callbacks = {
            k: lambda old_status, new_status: None
            for k in ["play", "pause", "seek", "speed_change", "end_of_file"]
        }

    def new_media_status(self, status: MediaStatus):
        for callback in self._callbacks.values():
            callback(self._old_status, status)
        self._old_status = copy(status)

    def load_media_failed(self, item: int, error_code: int):
        print(
            "[",
            time.ctime(),
            " - ",
            self.name,
            "] load media failed for item: ",
            item,
            " with code: ",
            error_code,
        )

    def on_play(self, func: Callable[[Optional[str]], None]) -> None:
        def callback(old_status: MediaStatus, new_status: MediaStatus) -> None:
            if (
                old_status is None
                or new_status.player_is_playing
                and not old_status.player_is_playing
            ):
                func(str(new_status.current_time))

        self._callbacks["play"] = callback

    def on_pause(self, func: Callable[[Optional[str]], None]) -> None:
        def callback(old_status: MediaStatus, new_status: MediaStatus) -> None:
            if (
                old_status is None
                or new_status.player_is_paused
                and not old_status.player_is_paused
            ):
                func(str(new_status.current_time))

        self._callbacks["pause"] = callback

    def on_seek(self, func: Callable[[Optional[str]], None]) -> None:
        def callback(old_status: MediaStatus, new_status: MediaStatus) -> None:
            if (
                old_status
                and abs(new_status.current_time - old_status.adjusted_current_time) > 5
            ):
                func(str(new_status.current_time))

        self._callbacks["seek"] = callback

    def on_speed_change(self, func: Callable[[float], None]) -> None:
        def callback(old_status: MediaStatus, new_status: MediaStatus) -> None:
            if old_status and new_status.playback_rate != old_status.playback_rate:
                func(new_status.playback_rate)

        self._callbacks["speed_change"] = callback

    def on_end_of_file(
        self, player: "Player", func: Callable[["Player"], None]
    ) -> None:
        def callback(old_status: MediaStatus, new_status: MediaStatus) -> None:
            if old_status and new_status.player_is_idle and new_status.idle_reason:
                t = threading.Thread(target=func, args=(player,))
                t.start()

        self._callbacks["end_of_file"] = callback


class Player:
    def __init__(self) -> None:
        cast: pychromecast.Chromecast = pychromecast.get_listed_chromecasts(
            friendly_names=[CAST_NAME]
        )[0][0]
        cast.wait()
        cast.media_controller.stop()
        listener = MyMediaStatusListener(cast.name)
        cast.media_controller.register_status_listener(listener)
        self._cast = cast
        self._mc = cast.media_controller
        self._listener = listener

    def is_running(self) -> bool:
        return self._cast is not None

    def current_pos(self) -> Optional[str]:
        return (
            None
            if self._mc is None or self._mc.status is None
            else str(self._mc.status.adjusted_current_time)
        )

    def play(self, url: str) -> None:
        content_type = (
            "application/x-mpegURL"
            if url.endswith(".m3u8")
            else "video/mp4"
            if url.endswith(".mp4")
            else None
        )
        app_data = {"media_id": url, "media_type": content_type, "autoplay": False}
        quick_play.quick_play(self._cast, APP_NAME, app_data)
        self._mc.block_until_active()
        self._mc.pause()

    def terminate(self) -> None:
        self._cast.quit_app()

    def on_play(self, func: Callable[[Optional[str]], None]) -> None:
        self._listener.on_play(func)

    def on_pause(self, func: Callable[[Optional[str]], None]) -> None:
        self._listener.on_pause(func)

    def on_seek(self, func: Callable[[Optional[str]], None]) -> None:
        self._listener.on_seek(func)

    def on_speed_change(self, func: Callable[[float], None]) -> None:
        self._listener.on_speed_change(func)

    def on_end_of_file(self, func: Callable[["Player"], None]) -> None:
        self._listener.on_end_of_file(self, func)
