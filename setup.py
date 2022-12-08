from setuptools import find_packages, setup

setup(
    name="twplay",
    version="0.1.0",
    packages=find_packages(),
    entry_points={"console_scripts": ["twplay = twitch_VOD_player.main:main"]},
    install_requires=[
        "flask",
        "flask_cors",
        "pika",
        "pychromecast",
        "pynput",
        "python_mpv_jsonipc",
    ],
)
