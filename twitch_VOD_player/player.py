from python_mpv_jsonipc import MPV


def is_running(mpv):
    return mpv.mpv_process.process.poll() is None


class Player:
    def __init__(self) -> None:
        self._mpv = MPV()  # Uses MPV that is in the PATH.

        @self._mpv.on_event("file-loaded")
        def on_loading(event_data):
            self._mpv.pause = "yes"

    def is_running(self):
        return self._mpv.mpv_process.process.poll() is None

    def current_pos(self):
        return self._mpv.time_pos

    def play(self, url):
        self._mpv.play(url)

    def terminate(self):
        self._mpv.terminate()

    def on_play(self, func):
        @self._mpv.property_observer("pause")
        def callback(property_name, pause):
            if self.current_pos():
                if not pause:
                    func(self.current_pos())

    def on_pause(self, func):
        @self._mpv.property_observer("pause")
        def callback(property_name, pause):
            if self.current_pos():
                if pause:
                    func(self.current_pos())

    def on_seek(self, func):
        @self._mpv.on_event("seek")
        def callback(event_data):
            if self.current_pos():
                func(self.current_pos())

    def on_end_of_file(self, func):
        @self._mpv.on_event("end-file")
        def callback(event_data):
            func(self)
