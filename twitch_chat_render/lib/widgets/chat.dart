import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/amqp_interface.dart';
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
  Streamer? streamer;
  List<Comment>? comments;
  TwitchBadges? badges;
  BTTVEmotes? bttvEmotes;
  TwitchCheerEmotes? cheerEmotes;
  int nextMessageIndex = 0;
  Duration updatePeriod = const Duration(milliseconds: 300);
  Timer? timer;
  double chatTime = 0;
  bool playing = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    retrieveComments();
    setupSync();
  }

  void play(double playerPosition) {
    playing = true;
    timer = Timer.periodic(updatePeriod, (Timer timer) {
      if (comments != null) {
        setState(() {
          forwardMessageIndex(playerPosition);
        });
      }
    });
  }

  void pause(double playerPosition) {
    playing = false;
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

  void seek(double playerPosition) {
    setState(() {
      bool wasPlaying = playing;
      if (wasPlaying) pause(playerPosition);
      if (playerPosition > chatTime) {
        forwardMessageIndex(playerPosition);
      } else {
        backwardMessageIndex(playerPosition);
      }
      if (wasPlaying) play(playerPosition);
    });
  }

  double elapsedTimerDuration() {
    return timer == null ? 0 : timer!.tick * updatePeriod.inMilliseconds / 1000;
  }

  void forwardMessageIndex(double playerPosition) {
    if (comments != null) {
      chatTime = playerPosition + elapsedTimerDuration();
      while (nextMessageIndex < comments!.length - 1 &&
          comments![nextMessageIndex].contentOffsetSeconds! < chatTime) {
        nextMessageIndex++;
      }
    }
  }

  void backwardMessageIndex(double playerPosition) {
    if (comments != null) {
      chatTime = playerPosition + elapsedTimerDuration();
      while (nextMessageIndex > 0 &&
          comments![nextMessageIndex - 1].contentOffsetSeconds! > chatTime) {
        nextMessageIndex--;
      }
    }
  }

  void retrieveComments() async {
    ChatModel chat = ChatModel.fromJson(await AmqpInterface().retriveChat());

    setState(() {
      streamer = chat.streamer;
      comments = chat.comments;
      fetchBadges();
      fetchEmotes();
      fetchCheerEmotes();
    });
  }

  void fetchBadges() async {
    badges = TwitchBadges(streamer: streamer);
    badges!.fetchBadges();
  }

  void fetchEmotes() async {
    bttvEmotes = BTTVEmotes(streamer: streamer);
    bttvEmotes!.fetchEmotes();
  }

  void fetchCheerEmotes() async {
    cheerEmotes = TwitchCheerEmotes(streamer: streamer);
    cheerEmotes!.fetchEmotes();
  }

  void setupSync() {
    AmqpInterface().setupSync(
        {"play": play, "pause": pause, "timer": adjustTimer, "seek": seek});
  }

  List<Comment>? activeComments() {
    return comments?.sublist(
        (nextMessageIndex - _maxMessageCount) >= 0
            ? (nextMessageIndex - _maxMessageCount)
            : 0,
        nextMessageIndex);
  }

  bool loaded() {
    return comments != null &&
        badges != null &&
        badges!.initialized() &&
        bttvEmotes != null &&
        bttvEmotes!.initialized() &&
        cheerEmotes != null &&
        cheerEmotes!.initialized();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
    return loaded()
        ? ListView.builder(
            controller: scrollController,
            itemCount: activeComments()?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return ChatMessage(
                  streamer: streamer,
                  comment: activeComments()?[index],
                  badges: badges);
            })
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
