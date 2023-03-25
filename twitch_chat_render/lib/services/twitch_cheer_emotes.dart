import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/twitch.dart';

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
    Map response = await Twitch.request({
      "query": """
                query {
                  cheerConfig {
                    displayConfig {colors {bits, color}}
                    groups {...CheermoteGroup}
                  }
                  user(id: ${streamer?.id}) {
                    cheer {cheerGroups {...CheermoteGroup}}
                  }
                }
                ${cheermoteGroupFragment()}
                """
    });
    List cheerGroups = List.from(response["data"]["cheerConfig"]["groups"])
      ..addAll(response["data"]["user"]["cheer"]?["cheerGroups"] ?? []);
    globalCheers ??= {
      for (var cheerGroup in cheerGroups)
        for (var cheermote in cheerGroup["nodes"])
          cheermote["prefix"]: {
            for (var tierToken in cheermote["tiers"])
              tierToken["bits"]: {
                "url": (cheerGroup["templateURL"] as String)
                    .replaceFirst(
                        "PREFIX", (cheermote["prefix"] as String).toLowerCase())
                    .replaceFirst("BACKGROUND", "dark")
                    .replaceFirst("ANIMATION", "animated")
                    .replaceFirst("TIER", tierToken["bits"].toString())
                    .replaceFirst("SCALE.EXTENSION", "1.gif"),
                "color": (response["data"]["cheerConfig"]["displayConfig"]
                        ["colors"] as List)
                    .firstWhere(
                        (el) => el["bits"] == tierToken["bits"])["color"]
              }
          }
    };
  }

  String cheermoteGroupFragment() {
    return "fragment CheermoteGroup on CheermoteGroup {nodes {id, prefix, tiers {bits}}, templateURL}";
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
