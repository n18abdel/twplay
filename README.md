# Dépendances

- [mpv](https://mpv.io/installation/) installé dans le PATH
- Une version récente de [youtube-dl](https://github.com/ytdl-org/youtube-dl)
- Python 3.6+
- [Flutter SDK](https://docs.flutter.dev/development/tools/sdk/releases) >=2.15.1 <3.0.0
- Une instance RabbitMQ tournant sur localhost:5672
- [TwitchDownloaderCLI](https://github.com/lay295/TwitchDownloader#linux--getting-started) installé dans le PATH

# Installation dépendances python

```bash
pip3 install -r requirements.txt
```

# Compilation de l'afficheur

```bash
cd twitch_chat_render/
```

Selon la plateforme, lancer une des commandes suivantes :

```bash
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
```

Puis l'une de celles-ci :

```bash
flutter build windows
flutter build macos
flutter build linux
```

L'executable se trouve à l'un des chemins suivants :

- windows : twitch_chat_render/build/windows/ ?
- macos : twitch_chat_render/build/macos/Build/Products/Release/twitch_chat_render.app
- linux : twitch_chat_render/build/linux/x64/release/bundle/twitch_chat_render

Plus d'informations sur la compilation d'un projet flutter [ici](https://docs.flutter.dev/desktop#build-a-release-app)

# Utilisation

Lancer l'afficheur à l'aide du fichier compilé

Lancer le controlleur de la manière suivante :

```bash
cd twitch_VOD_player/
python3 main.py https://www.twitch.tv/videos/<vod_id>
```

Une fenêtre MPV devrait s'ouvrir, il suffit de la positionner à côté de l'afficheur, et de démarrer la lecture.
