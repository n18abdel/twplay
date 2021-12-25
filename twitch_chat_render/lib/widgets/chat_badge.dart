import 'package:flutter/material.dart';
import 'package:twitch_chat_render/services/twitch_badges.dart';
import 'package:twitch_chat_render/widgets/utils.dart';

class ChatBadge extends StatelessWidget {
  const ChatBadge({Key? key, this.badge, this.badges}) : super(key: key);

  final TwitchBadges? badges;
  final dynamic badge;
  @override
  Widget build(BuildContext context) {
    return Utils.tooltip(
        context: context,
        url: badges!
            .getDownloadUrl(name: badge["_id"], version: badge["version"]),
        name: badges!.getTitle(name: badge["_id"], version: badge["version"]));
  }
}
