import threading
from typing import Callable, Optional

from python_mpv_jsonipc import MPV


class Player:
    def __init__(self) -> None:
        self._mpv = MPV()  # Uses MPV that is in the PATH.

        @self._mpv.on_event("file-loaded")
        def on_loading(event_data: dict) -> None:
            self._mpv.pause = "yes"

    def is_running(self) -> bool:
        return self._mpv.mpv_process.process.poll() is None

    def current_pos(self) -> Optional[str]:
        return None if self._mpv.time_pos is None else str(self._mpv.time_pos)

    def play(self, url: str) -> None:
        options = {
            "hwdec": "auto",
            "stream-lavf-o-append": (
                "protocol_whitelist=" "file,http,https,tcp,tls,crypto,hls,applehttp"
            ),
            "merge-files": "yes",
        }
        if "http" in url:
            options.update(
                {
                    "cache": "yes",
                    "demuxer-max-bytes": "100MiB",
                    "demuxer-max-back-bytes": "100MiB",
                }
            )
        self._mpv.command(
            {
                "name": "loadfile",
                "url": url,
                "options": options,
            }
        )

    def terminate(self) -> None:
        self._mpv.terminate()

    def get_speed(self) -> float:
        return self._mpv.speed

    def set_speed(self, speed: float) -> None:
        self._mpv.speed = speed

    def on_play(self, func: Callable[[Optional[str]], None]) -> None:
        @self._mpv.property_observer("pause")
        def callback(property_name: str, pause: bool) -> None:
            if self.current_pos():
                if not pause:
                    func(self.current_pos())

    def on_pause(self, func: Callable[[Optional[str]], None]) -> None:
        @self._mpv.property_observer("pause")
        def callback(property_name: str, pause: bool) -> None:
            if self.current_pos():
                if pause:
                    func(self.current_pos())

    def on_seek(self, func: Callable[[Optional[str]], None]) -> None:
        @self._mpv.on_event("seek")
        def callback(event_data: dict) -> None:
            if self.current_pos():
                func(self.current_pos())

    def on_speed_change(self, func: Callable[[float], None]) -> None:
        @self._mpv.property_observer("speed")
        def callback(property_name: str, speed: float) -> None:
            func(speed)

    def on_end_of_file(self, func: Callable[["Player"], None]) -> None:
        @self._mpv.on_event("end-file")
        def callback(event_data: dict) -> None:
            if event_data["reason"] != "redirect":
                t = threading.Thread(target=func, args=(self,))
                t.start()
