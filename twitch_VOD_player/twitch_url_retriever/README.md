# Twitch url retriever

Twitch url retriever allows you to retrieve the link of a Twitch VOD.

## Dependencies

- Python 3.9+
- Java 1.8+
- [TwitchRecover](https://github.com/n18abdel/TwitchRecover/releases/tag/v1.0.0)

## Installation

### TwitchRecover dependency

- Download the [TwitchRecover JAR](https://github.com/n18abdel/TwitchRecover/releases/tag/v1.0.0)
- Edit the [twrec](twrec) file to point to the downloaded JAR
- Put the edited file [twrec](twrec) in the PATH

### twitch_url_retriever

```bash
pip3 install .
```

## Basic usage

```bash
twitch_url_retriever https://www.twitch.tv/videos/<vod_id>
```

- Twitchtracker (may not work)

```bash
twitch_url_retriever https://twitchtracker.com/<streamer_name>/streams/<stream_id>
```

- Help

```bash
twitch_url_retriever --help
```

## Thanks

I would like to thank [Daylam Tayari](https://github.com/daylamtayari) for making [TwitchRecover](https://github.com/TwitchRecover/TwitchRecover) !
