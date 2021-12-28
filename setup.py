from setuptools import find_packages, setup

setup(
    name="twplay",
    version="0.1.0",
    packages=find_packages(),
    entry_points={"console_scripts": ["twplay = twitch_VOD_player.main:main"]},
)
