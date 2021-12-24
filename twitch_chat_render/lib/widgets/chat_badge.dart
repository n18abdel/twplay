import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:twitch_chat_render/services/twitch_badges.dart';

class ChatBadge extends StatelessWidget {
  const ChatBadge({Key? key, this.badge, this.badges}) : super(key: key);

  final TwitchBadges? badges;
  final dynamic badge;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      placeholder: (context, url) => const CircularProgressIndicator(),
      imageUrl:
          badges!.getDownloadUrl(name: badge["_id"], version: badge["version"]),
    );
  }
}
