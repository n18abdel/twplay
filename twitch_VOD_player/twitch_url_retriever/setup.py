from setuptools import find_packages, setup

setup(
    name="twitch_url_retriever",
    version="0.1.0",
    packages=find_packages(),
    entry_points={
        "console_scripts": ["twitch_url_retriever = twitch_url_retriever.main:main"]
    },
)
