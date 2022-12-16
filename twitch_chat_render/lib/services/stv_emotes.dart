import 'dart:convert';

import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:http/http.dart' as http;

class STVEmotes {
  Streamer? streamer;

  Map? globalEmotes;
  Map? channelEmotes;

  STVEmotes._privateConstructor();

  static final STVEmotes _instance = STVEmotes._privateConstructor();

  factory STVEmotes({Streamer? streamer}) {
    _instance.streamer ??= streamer;
    return _instance;
  }

  Future<void> fetchEmotes() async {
    globalEmotes ??= {
      for (var emote in jsonDecode(
          (await http.get(Uri.parse("https://7tv.io/v3/emote-sets/global")))
              .body)["emotes"])
        emote["name"]: "https:${emote["data"]["host"]["url"]}/1x"
    };
    Map channelResponse = jsonDecode((await http
            .get(Uri.parse("https://7tv.io/v3/users/twitch/${streamer?.id}")))
        .body);
    channelEmotes ??= {
      for (var emote in channelResponse["emote_set"]?["emotes"] ?? [])
        emote["name"]: "https:${emote["data"]["host"]["url"]}/1x"
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
