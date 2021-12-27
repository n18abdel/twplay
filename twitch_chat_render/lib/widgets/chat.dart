import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/amqp_interface.dart';
import 'package:twitch_chat_render/models/app_status.dart';
import 'package:twitch_chat_render/services/bttv_emotes.dart';
import 'package:twitch_chat_render/services/twitch_badges.dart';
import 'package:twitch_chat_render/services/twitch_cheer_emotes.dart';
import 'package:twitch_chat_render/widgets/chat_message.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final int _maxMessageCount = 200;
  Streamer? get streamer =>
      Provider.of<AppStatus>(context, listen: false).streamer;
  List<Comment>? get comments =>
      Provider.of<AppStatus>(context, listen: false).comments;
  TwitchBadges? get badges =>
      Provider.of<AppStatus>(context, listen: false).badges;
  BTTVEmotes? get bttvEmotes =>
      Provider.of<AppStatus>(context, listen: false).bttvEmotes;
  TwitchCheerEmotes? get cheerEmotes =>
      Provider.of<AppStatus>(context, listen: false).cheerEmotes;
  int nextMessageIndex = 0;
  Duration updatePeriod = const Duration(milliseconds: 300);
  Timer? timer;
  double chatTime = 0;
  double chatSpeed = 1;
  double chatOffset = 0;
  bool get playing => Provider.of<AppStatus>(context, listen: false).playing;
  bool get initStatus =>
      Provider.of<AppStatus>(context, listen: false).initStatus;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    setupSync();
    context.read<AppStatus>().addListener(() {
      var newOffset = context.read<AppStatus>().offset;
      if (newOffset != chatOffset) {
        chatOffset = newOffset;
        seek(chatTime);
      }
    });
  }

  void play(double playerPosition) {
    context.read<AppStatus>().play();
    chatTime = playerPosition;
    timer = Timer.periodic(updatePeriod, (Timer timer) {
      if (comments != null) {
        setState(() {
          chatTime += chatSpeed * updatePeriod.inMilliseconds / 1000;
          forwardMessageIndex(playerPosition);
        });
      }
    });
  }

  void pause(double playerPosition) {
    context.read<AppStatus>().pause();
    timer?.cancel();
  }

  void adjustTimer(double playerPosition) {
    if (playing) {
      pause(playerPosition);
      play(playerPosition);
    } else {
      setState(() {
        forwardMessageIndex(playerPosition);
      });
    }
  }

  void adjustSpeed(double playerSpeed) {
    setState(() {
      bool wasPlaying = playing;
      if (wasPlaying) pause(chatTime);
      chatSpeed = playerSpeed;
      if (wasPlaying) play(chatTime);
    });
    Provider.of<AppStatus>(context, listen: false).setSpeed(playerSpeed);
  }

  void seek(double playerPosition) {
    setState(() {
      bool wasPlaying = playing;
      if (wasPlaying) pause(playerPosition);
      forwardMessageIndex(playerPosition);
      backwardMessageIndex(playerPosition);
      if (wasPlaying) play(playerPosition);
    });
  }

  void forwardMessageIndex(double startPosition) {
    if (comments != null) {
      while (nextMessageIndex < comments!.length - 1 &&
          comments![nextMessageIndex].contentOffsetSeconds! <
              chatTime + chatOffset) {
        nextMessageIndex++;
      }
    }
  }

  void backwardMessageIndex(double startPosition) {
    if (comments != null) {
      while (nextMessageIndex > 0 &&
          comments![nextMessageIndex - 1].contentOffsetSeconds! >
              chatTime + chatOffset) {
        nextMessageIndex--;
      }
    }
  }

  void setupSync() {
    AmqpInterface().setupSync({
      "play": play,
      "pause": pause,
      "timer": adjustTimer,
      "seek": seek,
      "speed": adjustSpeed
    });
  }

  List<Comment>? activeComments() {
    return comments?.sublist(
        (nextMessageIndex - _maxMessageCount) >= 0
            ? (nextMessageIndex - _maxMessageCount)
            : 0,
        nextMessageIndex);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
          controller: scrollController,
          itemCount: activeComments()?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            return ChatMessage(
                streamer: streamer,
                comment: activeComments()?[index],
                badges: badges);
          }),
    );
  }
}
