import 'dart:convert';

import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:http/http.dart' as http;

class TwitchBadges {
  Streamer? streamer;

  Map? globalBadges;
  Map? subBadges;

  TwitchBadges._privateConstructor();

  static final TwitchBadges _instance = TwitchBadges._privateConstructor();

  factory TwitchBadges({Streamer? streamer}) {
    _instance.streamer ??= streamer;
    return _instance;
  }

  Future<void> fetchBadges() async {
    globalBadges ??= jsonDecode((await http.get(
            Uri.parse("https://badges.twitch.tv/v1/badges/global/display")))
        .body)["badge_sets"];
    subBadges ??= jsonDecode((await http.get(Uri.parse(
            "https://badges.twitch.tv/v1/badges/channels/${streamer?.id}/display")))
        .body)["badge_sets"];
  }

  bool initialized() {
    return globalBadges != null && subBadges != null;
  }

  String getDownloadUrl({name, version}) {
    while (globalBadges == null || subBadges == null) {}
    return (subBadges?[name] ?? globalBadges?[name])["versions"][version]
        ["image_url_2x"];
  }

  String getTitle({name, version}) {
    while (globalBadges == null || subBadges == null) {}
    return (subBadges?[name] ?? globalBadges?[name])["versions"][version]
        ["title"];
  }
}
