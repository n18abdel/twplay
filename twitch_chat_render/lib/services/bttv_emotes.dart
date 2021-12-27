import 'dart:convert';

import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:http/http.dart' as http;

class BTTVEmotes {
  Streamer? streamer;

  Map? globalEmotes;
  Map? channelEmotes;

  BTTVEmotes._privateConstructor();

  static final BTTVEmotes _instance = BTTVEmotes._privateConstructor();

  factory BTTVEmotes({Streamer? streamer}) {
    _instance.streamer ??= streamer;
    return _instance;
  }

  Future<void> fetchEmotes() async {
    globalEmotes ??= {
      for (var emote in jsonDecode((await http.get(
              Uri.parse("https://api.betterttv.net/3/cached/emotes/global")))
          .body))
        emote["code"]: "https://cdn.betterttv.net/emote/${emote["id"]}/2x"
    };
    Map channelResponse = jsonDecode((await http.get(Uri.parse(
            "https://api.betterttv.net/3/cached/users/twitch/${streamer?.id}")))
        .body);
    channelEmotes ??= {
      for (var emote in [
        ...channelResponse["sharedEmotes"] ?? [],
        ...channelResponse["channelEmotes"] ?? []
      ])
        emote["code"]: "https://cdn.betterttv.net/emote/${emote["id"]}/2x"
    };
  }

  bool initialized() {
    return globalEmotes != null && channelEmotes != null;
  }

  String? getDownloadUrl({name}) {
    while (globalEmotes == null || channelEmotes == null) {}
    return (channelEmotes?[name] ?? globalEmotes?[name]);
  }
}
