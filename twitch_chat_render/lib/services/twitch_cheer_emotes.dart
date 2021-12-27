import 'dart:convert';

import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:http/http.dart' as http;

class TwitchCheerEmotes {
  Streamer? streamer;

  Map? globalCheers;

  TwitchCheerEmotes._privateConstructor();

  static final TwitchCheerEmotes _instance =
      TwitchCheerEmotes._privateConstructor();

  factory TwitchCheerEmotes({Streamer? streamer}) {
    _instance.streamer ??= streamer;
    return _instance;
  }

  Future<void> fetchEmotes() async {
    Map response = jsonDecode((await http.get(
            Uri.parse(
                "https://api.twitch.tv/kraken/bits/actions?channel_id=${streamer?.id}"),
            headers: {
          "Accept": "application/vnd.twitchtv.v5+json",
          "Client-ID": "kimne78kx3ncx6brgo4mv6wki5h1ko"
        }))
        .body);
    globalCheers ??= {
      for (var emoteToken in response['actions'])
        emoteToken["prefix"]: {
          for (var tierToken in emoteToken["tiers"])
            tierToken["min_bits"]: {
              "url": tierToken["images"]["dark"]["animated"]["1"],
              "color": tierToken["color"]
            }
        }
    };
  }

  bool initialized() {
    return globalCheers != null;
  }

  String getAmount({name}) {
    return name.substring(name.indexOf(RegExp(r'\d')), name.length);
  }

  String getPrefix({name}) {
    return name.substring(0, name.indexOf(RegExp(r'\d')));
  }

  String getDownloadUrl({name}) {
    while (globalCheers == null) {}
    return globalCheers?[getPrefix(name: name)]?[getTier(name: name)]["url"];
  }

  String getColor({name}) {
    while (globalCheers == null) {}
    return globalCheers?[getPrefix(name: name)]?[getTier(name: name)]["color"];
  }

  bool isCheer({name}) {
    return RegExp(r"^[a-zA-Z]+[0-9]+$").hasMatch(name) &&
        globalCheers?[getPrefix(name: name)] != null;
  }

  int getTier({name}) {
    List<int> tierList = List.from(globalCheers?[getPrefix(name: name)]?.keys);
    tierList.sort();
    int amount = int.parse(getAmount(name: name));
    return tierList[tierList.lastIndexWhere((tier) => amount >= tier)];
  }
}
