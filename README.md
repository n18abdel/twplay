# Twplay

Twplay allows you to watch a Twitch VOD while displaying the chat in sync.

## Features

- BTTV and 7TV Emotes
- Chromecast (for now only in the python version, on branch [dev/python](https://github.com/n18abdel/twplay/tree/dev/python))
- Sync offset between player and chat

## Examples

![](images/example.png)
![](images/offset.png)

## Dependencies

- [Elixir](https://elixir-lang.org)
- [Flutter SDK](https://docs.flutter.dev/development/tools/sdk/releases)
- [mpv](https://mpv.io/installation/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Twitch CLI](https://dev.twitch.tv/docs/cli/)
- [TwitchDownloaderCLI](https://github.com/lay295/TwitchDownloader#cli)

## Installation

**THIS WAS TESTED ONLY ON MAC OS**

### Chat renderer

```bash
cd twitch_chat_render/
flutter config --enable-macos-desktop
flutter build macos --release
cp -r build/macos/Build/Products/Release/twitch_chat_render.app /Applications
```

For other platforms, more information [here](https://docs.flutter.dev/desktop#build-a-release-app).

### twplay

```bash
cd twplay/
MIX_ENV=prod mix escript.install --force
```

## Basic usage

```bash
twplay https://www.twitch.tv/videos/<vod_id>
```

A MPV window should open, with a chat render window. You just need to position them side by side, and then you can start the playback.

- Twitchtracker

```bash
twplay https://twitchtracker.com/<streamer_name>/streams/<stream_id>
```

- Chromecast (**UPCOMING**)

```bash
twplay https://www.twitch.tv/videos/<vod_id> --cast
```

- Help

```bash
twplay --help
```

## Debugging

You can launch a REPL in the context if this app, using the following command:

```bash
iex --remsh twplay@<host> --sname <name>
```

where `<host` is the name of your device, and `<name>` is a name of your choice.

Upon launching the app, the `<host` will be printed in the console.
## Thanks

I would like to thank [Lewis Pardo](https://github.com/lay295) for making [TwitchDownloaderCLI](https://github.com/TwitchRecover/TwitchRecover), and inspiring me to do this project !
