import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/amqp_interface.dart';
import 'package:twitch_chat_render/models/app_status.dart';
import 'package:twitch_chat_render/services/bttv_emotes.dart';
import 'package:twitch_chat_render/services/twitch_badges.dart';
import 'package:twitch_chat_render/services/twitch_cheer_emotes.dart';
import 'package:twitch_chat_render/widgets/chat_message.dart';
import 'package:wakelock/wakelock.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
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
  int get nextMessageIndex =>
      Provider.of<AppStatus>(context, listen: false).nextMessageIndex;
  Duration updatePeriod = const Duration(milliseconds: 300);
  Timer? timer;
  Stopwatch stopwatch = Stopwatch();
  double chatInitPosition = 0;
  double chatSpeed = 1;
  double get chatTime =>
      chatInitPosition + chatSpeed * stopwatch.elapsed.inMilliseconds / 1000;
  double chatOffset = 0;
  bool get playing => Provider.of<AppStatus>(context, listen: false).playing;
  bool get initStatus =>
      Provider.of<AppStatus>(context, listen: false).initStatus;
  bool shouldScroll = true;
  Timer? scrollTimeout;
  ScrollController controller = ScrollController();

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
    chatInitPosition = playerPosition;
    stopwatch
      ..reset()
      ..start();
    timer = Timer.periodic(updatePeriod, (Timer timer) {
      if (comments != null) {
        int oldNextMessageIndex = nextMessageIndex;
        forwardMessageIndex();
        backwardMessageIndex();
        if (nextMessageIndex != oldNextMessageIndex) {
          setState(() {});
        }
      }
    });
  }

  void pause(double playerPosition) {
    context.read<AppStatus>().pause();
    timer?.cancel();
    stopwatch.stop();
  }

  void adjustTimer(double playerPosition) {
    chatInitPosition = playerPosition;
    stopwatch.reset();
  }

  void adjustSpeed(double playerSpeed) {
    adjustTimer(chatTime);
    chatSpeed = playerSpeed;
    Provider.of<AppStatus>(context, listen: false).setSpeed(playerSpeed);
  }

  void seek(double playerPosition) {
    int oldNextMessageIndex = nextMessageIndex;
    bool wasPlaying = playing;
    if (wasPlaying) pause(playerPosition);
    forwardMessageIndex();
    backwardMessageIndex();
    if (nextMessageIndex != oldNextMessageIndex) {
      setState(() {});
    }
    if (wasPlaying) play(playerPosition);
  }

  void forwardMessageIndex() {
    if (comments != null && shouldScroll) {
      double lookupTime = chatTime + chatOffset;
      while (nextMessageIndex < comments!.length - 1 &&
          comments![nextMessageIndex].contentOffsetSeconds! < lookupTime) {
        context.read<AppStatus>().incNextMessageIndex();
      }
    }
  }

  void backwardMessageIndex() {
    if (comments != null && shouldScroll) {
      double lookupTime = chatTime + chatOffset;
      while (nextMessageIndex > 0 &&
          comments![nextMessageIndex - 1].contentOffsetSeconds! > lookupTime) {
        context.read<AppStatus>().decNextMessageIndex();
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

  void resumeScrolling() {
    controller.jumpTo(0);
    setState(() => shouldScroll = true);
  }

  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    return Stack(
      children: <Widget>[
        if (!shouldScroll)
          Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.bottomCenter,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_downward),
              style: ButtonStyle(
                  overlayColor:
                      MaterialStateProperty.all<Color>(Colors.redAccent),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  elevation: MaterialStateProperty.all<double>(100),
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.red.withOpacity(1))),
              label: const Text('Resume scrolling'),
              onPressed: null,
            ),
          ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onTap: resumeScrolling,
          onHover: (value) {
            if (scrollTimeout != null) scrollTimeout!.cancel();
            if (value) {
              setState(() => shouldScroll = false);
            } else {
              scrollTimeout =
                  Timer(const Duration(seconds: 10), resumeScrolling);
            }
          },
          child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: ListView.builder(
                controller: controller,
                reverse: true,
                cacheExtent: 0,
                itemCount: min(comments!.length, nextMessageIndex),
                itemBuilder: (BuildContext context, int index) => ChatMessage(
                    streamer: streamer,
                    comment: comments![nextMessageIndex - index],
                    badges: badges),
              )),
        ),
      ],
    );
  }
}
