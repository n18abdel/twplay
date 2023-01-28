import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/amqp_interface.dart';
import 'package:twitch_chat_render/services/bttv_emotes.dart';
import 'package:twitch_chat_render/services/stv_emotes.dart';
import 'package:twitch_chat_render/services/twitch_badges.dart';
import 'package:twitch_chat_render/services/twitch_cheer_emotes.dart';

class AppStatus with ChangeNotifier {
  bool playing = false;
  double speed = 1;
  double offset = 0;
  static const double offsetIncrement = 0.5;
  Streamer? streamer;
  List<Comment>? comments;
  TwitchBadges? badges;
  BTTVEmotes? bttvEmotes;
  STVEmotes? stvEmotes;
  TwitchCheerEmotes? cheerEmotes;
  bool initStatus = false;
  int nextMessageIndex = 0;
  bool shouldScroll = true;
  ScrollController controller = ScrollController();
  Timer? scrollTimeout;
  String? amqpHost;

  void play() {
    playing = true;
    notifyListeners();
  }

  void pause() {
    playing = false;
    notifyListeners();
  }

  void setSpeed(double s) {
    speed = s;
    notifyListeners();
  }

  void setOffset(double o) {
    offset = o;
    notifyListeners();
  }

  void incOffset() {
    offset += offsetIncrement;
    notifyListeners();
  }

  void decOffset() {
    offset -= offsetIncrement;
    notifyListeners();
  }

  void fetchChat() async {
    ChatModel chat =
        ChatModel.fromJson(await AmqpInterface().retriveChat(amqpHost ?? ''));
    streamer = chat.streamer;
    comments = chat.comments;
    fetchBadges();
    fetchBTTVEmotes();
    fetchSTVEmotes();
    fetchCheerEmotes();
    notifyListeners();
  }

  void fetchBadges() {
    badges = TwitchBadges(streamer: streamer);
    badges!.fetchBadges().then((value) => notifyListeners());
  }

  void fetchBTTVEmotes() {
    bttvEmotes = BTTVEmotes(streamer: streamer);
    bttvEmotes!.fetchEmotes().then((value) => notifyListeners());
  }

  void fetchSTVEmotes() {
    stvEmotes = STVEmotes(streamer: streamer);
    stvEmotes!.fetchEmotes().then((value) => notifyListeners());
  }

  void fetchCheerEmotes() {
    cheerEmotes = TwitchCheerEmotes(streamer: streamer);
    cheerEmotes!.fetchEmotes().then((value) => notifyListeners());
  }

  bool loaded() {
    if (!initStatus) {
      initStatus = comments != null &&
          badges != null &&
          badges!.initialized() &&
          bttvEmotes != null &&
          bttvEmotes!.initialized() &&
          stvEmotes != null &&
          stvEmotes!.initialized() &&
          cheerEmotes != null &&
          cheerEmotes!.initialized();
    }
    return initStatus;
  }

  void incNextMessageIndex() {
    nextMessageIndex++;
  }

  void decNextMessageIndex() {
    nextMessageIndex--;
  }

  void resumeScrolling() {
    shouldScroll = true;
    controller.jumpTo(0);
    notifyListeners();
  }

  void stopScolling() {
    shouldScroll = false;
    hoverChat();
    notifyListeners();
  }

  void hoverChat() {
    if (scrollTimeout != null) scrollTimeout!.cancel();
    if (!shouldScroll) {
      scrollTimeout = Timer(const Duration(seconds: 3), resumeScrolling);
    }
  }

  void setAmqpHost(String h) {
    amqpHost = h;
  }
}
