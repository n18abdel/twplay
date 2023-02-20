import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/amqp_interface.dart';
import 'package:twitch_chat_render/models/app_status.dart';
import 'package:twitch_chat_render/services/twitch_badges.dart';
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
  bool get shouldScroll =>
      Provider.of<AppStatus>(context, listen: false).shouldScroll;
  ScrollController get controller =>
      Provider.of<AppStatus>(context, listen: false).controller;

  @override
  void initState() {
    super.initState();
    setupSync();
    controller.addListener(scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    disposeSync();
    controller.removeListener(scrollListener);
  }

  void scrollListener() {
    controller.position.isScrollingNotifier.addListener(() {
      if (controller.position.isScrollingNotifier.value) {
        stopScrolling();
      }
    });
  }

  void offsetListener() {
    var newOffset = context.read<AppStatus>().offset;
    if (newOffset != chatOffset) {
      chatOffset = newOffset;
      seek(chatTime);
    }
  }

  void play(double playerPosition) {
    Wakelock.enable();
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
    Wakelock.disable();
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
      while (nextMessageIndex < comments!.length &&
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
    context.read<AppStatus>().addListener(offsetListener);
  }

  void disposeSync() {
    AmqpInterface().disposeSync();
    context.read<AppStatus>().removeListener(offsetListener);
  }

  void resumeScrolling() {
    context.read<AppStatus>().resumeScrolling();
  }

  void stopScrolling() {
    context.read<AppStatus>().stopScolling();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          controller: controller,
          reverse: true,
          cacheExtent: 0,
          itemCount: nextMessageIndex,
          itemBuilder: (BuildContext context, int index) => ChatMessage(
              streamer: streamer,
              comment: comments![nextMessageIndex - 1 - index],
              index: nextMessageIndex - 1 - index,
              badges: badges),
        ));
  }
}
