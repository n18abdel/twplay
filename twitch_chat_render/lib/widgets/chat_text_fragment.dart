import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/bttv_emotes.dart';
import 'package:twitch_chat_render/services/twitch_cheer_emotes.dart';
import 'package:twitch_chat_render/widgets/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatTextFragment {
  const ChatTextFragment({required this.fragment, this.streamer});

  final Streamer? streamer;
  final String fragment;

  List<String> tokenize(String fragment) {
    String leadingSpaces = RegExp(r'^\s*').stringMatch(fragment) ?? "";
    String trailingSpaces = RegExp(r'\s*$').stringMatch(fragment) ?? "";

    List<String> innerFragments = fragment.trim().split(RegExp('\\s+'));

    List<String> spaces = fragment.trim().split(RegExp('\\S+'));

    List<String> tokens = [leadingSpaces];
    for (var i = 0; i < innerFragments.length; i++) {
      tokens.addAll([spaces[i], innerFragments[i]]);
    }
    tokens.add(trailingSpaces);

    return tokens;
  }

  TextSpan from(BuildContext context) {
    List<String> tokens = tokenize(fragment);
    List<InlineSpan> spans = [];
    for (var token in tokens) {
      String? url = BTTVEmotes(streamer: streamer).getDownloadUrl(name: token);
      bool isText = url == null;
      bool isBTTVEmote = url != null;
      if (isBTTVEmote) {
        spans.add(Utils.emoteWrapper(context: context, url: url, name: token));
      } else if (TwitchCheerEmotes(streamer: streamer).isCheer(name: token)) {
        spans.addAll([
          Utils.emoteWrapper(
              context: context,
              url: TwitchCheerEmotes(streamer: streamer)
                  .getDownloadUrl(name: token),
              name: token),
          TextSpan(
              text:
                  " ${TwitchCheerEmotes(streamer: streamer).getAmount(name: token)}",
              style: TextStyle(
                  color: HexColor(TwitchCheerEmotes(streamer: streamer)
                      .getColor(name: token)),
                  fontWeight: FontWeight.bold))
        ]);
      } else if (isText) {
        Uri? uri = Uri.tryParse(token);
        bool isUrl =
            uri != null && uri.hasAbsolutePath && uri.scheme.startsWith('http');
        bool isMention = token.startsWith("@");
        spans.add(isMention
            ? WidgetSpan(
                child: Utils.clickableUsername(
                    child: Text(token,
                        style: TextStyle(
                            color: Theme.of(context).indicatorColor,
                            fontWeight: FontWeight.bold)),
                    context: context,
                    displayName: token.replaceFirst("@", "")))
            : TextSpan(
                recognizer: isUrl
                    ? (TapGestureRecognizer()
                      ..onTap = () async => await launch(token))
                    : null,
                text: token,
                style: TextStyle(
                    color: isUrl ? Colors.blue : null,
                    decoration: isUrl ? TextDecoration.underline : null)));
      }
    }
    return TextSpan(children: spans);
  }
}
