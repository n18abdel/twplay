import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/amqp_interface.dart';
import 'package:twitch_chat_render/services/app_status.dart';
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
  double chatSpeed = 1;
  double chatOffset = 0;
  bool playing = false;
  bool initStatus = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    retrieveComments();
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
    print("play - chat $chatTime player $playerPosition");
    playing = true;
    timer = Timer.periodic(updatePeriod, (Timer timer) {
      if (comments != null) {
        setState(() {
          forwardMessageIndex(playerPosition);
        });
      }
    });
    Provider.of<AppStatus>(context, listen: false).play();
  }

  void pause(double playerPosition) {
    print("pause - chat $chatTime player $playerPosition");
    print("index $nextMessageIndex");
    playing = false;
    timer?.cancel();
    Provider.of<AppStatus>(context, listen: false).pause();
  }

  void adjustTimer(double playerPosition) {
    print("timer - chat $chatTime player $playerPosition");
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
    print("speed - chat $chatSpeed player $playerSpeed");
    setState(() {
      bool wasPlaying = playing;
      if (wasPlaying) pause(chatTime);
      chatSpeed = playerSpeed;
      if (wasPlaying) play(chatTime);
    });
    Provider.of<AppStatus>(context, listen: false).setSpeed(playerSpeed);
  }

  void seek(double playerPosition) {
    print("seek - chat $chatTime player $playerPosition");
    setState(() {
      bool wasPlaying = playing;
      if (wasPlaying) pause(playerPosition);
      forwardMessageIndex(playerPosition);
      backwardMessageIndex(playerPosition);
      if (wasPlaying) play(playerPosition);
    });
  }

  double elapsedTimerDuration() {
    return timer == null
        ? 0
        : chatSpeed * timer!.tick * updatePeriod.inMilliseconds / 1000;
  }

  void forwardMessageIndex(double startPosition) {
    if (comments != null) {
      chatTime = startPosition + elapsedTimerDuration();
      while (nextMessageIndex < comments!.length - 1 &&
          comments![nextMessageIndex].contentOffsetSeconds! <
              chatTime + chatOffset) {
        nextMessageIndex++;
      }
    }
  }

  void backwardMessageIndex(double startPosition) {
    if (comments != null) {
      chatTime = startPosition + elapsedTimerDuration();
      while (nextMessageIndex > 0 &&
          comments![nextMessageIndex - 1].contentOffsetSeconds! >
              chatTime + chatOffset) {
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

  bool loaded() {
    if (!initStatus) {
      initStatus = comments != null &&
          badges != null &&
          badges!.initialized() &&
          bttvEmotes != null &&
          bttvEmotes!.initialized() &&
          cheerEmotes != null &&
          cheerEmotes!.initialized();
      if (initStatus) {
        WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
          Provider.of<AppStatus>(context, listen: false).didLoad();
        });
      }
    }
    return initStatus;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
    return loaded()
        ? ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView.builder(
                controller: scrollController,
                itemCount: activeComments()?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return ChatMessage(
                      streamer: streamer,
                      comment: activeComments()?[index],
                      badges: badges);
                }),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
