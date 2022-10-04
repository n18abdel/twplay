from abc import ABC, abstractmethod
from typing import Callable, Optional

SPEEDS = [0.5, 1, 1.5, 2]


class Player(ABC):
    @property
    @abstractmethod
    def is_running(self) -> bool:
        pass

    @property
    @abstractmethod
    def current_pos(self) -> Optional[str]:
        pass

    @abstractmethod
    def play(self, url: str) -> None:
        pass

    @abstractmethod
    def terminate(self) -> None:
        pass

    @property
    @abstractmethod
    def speed(self) -> float:
        pass

    @speed.setter
    @abstractmethod
    def speed(self, speed: float) -> None:
        pass

    def speed_up(self) -> None:
        new_speed = next((speed for speed in SPEEDS if speed > self.speed), None)
        if new_speed:
            self.speed = new_speed

    def slow_down(self) -> None:
        new_speed = next(
            (speed for speed in reversed(SPEEDS) if speed < self.speed), None
        )
        if new_speed:
            self.speed = new_speed

    @abstractmethod
    def backward(self) -> None:
        pass

    @abstractmethod
    def forward(self) -> None:
        pass

    @abstractmethod
    def toggle_play(self) -> None:
        pass

    @abstractmethod
    def seek(self, position: str) -> None:
        pass

    @abstractmethod
    def on_play(self, func: Callable[[Optional[str]], None]) -> None:
        pass

    @abstractmethod
    def on_pause(self, func: Callable[[Optional[str]], None]) -> None:
        pass

    @abstractmethod
    def on_seek(self, func: Callable[[Optional[str]], None]) -> None:
        pass

    @abstractmethod
    def on_speed_change(self, func: Callable[[str], None]) -> None:
        pass

    @abstractmethod
    def on_end_of_file(self, func: Callable[["Player"], None]) -> None:
        pass
