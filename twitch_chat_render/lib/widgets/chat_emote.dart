import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatEmote extends StatelessWidget {
  const ChatEmote({Key? key, this.emoticon}) : super(key: key);

  final dynamic emoticon;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      placeholder: (context, url) => const CircularProgressIndicator(),
      imageUrl:
          'https://static-cdn.jtvnw.net/emoticons/v2/${emoticon["emoticon_id"]}/default/dark/2.0',
    );
  }
}
