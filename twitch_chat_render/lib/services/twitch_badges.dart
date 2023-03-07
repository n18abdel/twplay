import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/twitch.dart';

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
    globalBadges ??= aggregate((await Twitch.request(
            {"query": "query {badges{...Badge}} ${badgeFragment()}"}))["data"]
        ["badges"]);

    subBadges ??= aggregate((await Twitch.request({
      "query":
          "query {user(id: ${streamer?.id}) {broadcastBadges {...Badge}}} ${badgeFragment()}"
    }))["data"]["user"]["broadcastBadges"]);
  }

  String badgeFragment() {
    return "fragment Badge on Badge {title,setID,version,imageURL}";
  }

  Map aggregate(List badges) {
    return badges.fold({}, (Map agg, badge) {
      return {
        ...agg,
        badge["setID"]: {
          ...(agg[badge["setID"]] ?? {}),
          badge["version"]: {
            "image_url": badge["imageURL"],
            "title": badge["title"]
          }
        }
      };
    });
  }

  bool initialized() {
    return globalBadges != null && subBadges != null;
  }

  String getDownloadUrl({name, version}) {
    while (globalBadges == null || subBadges == null) {}
    return (subBadges?[name]?[version] ??
        globalBadges?[name]?[version])["image_url"];
  }

  String getTitle({name, version}) {
    while (globalBadges == null || subBadges == null) {}
    return (subBadges?[name]?[version] ??
        globalBadges?[name]?[version])["title"];
  }
}
