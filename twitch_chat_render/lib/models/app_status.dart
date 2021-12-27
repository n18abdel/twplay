import 'package:flutter/material.dart';
import 'package:twitch_chat_render/models/chat_model.dart';
import 'package:twitch_chat_render/services/amqp_interface.dart';
import 'package:twitch_chat_render/services/bttv_emotes.dart';
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
  TwitchCheerEmotes? cheerEmotes;
  bool initStatus = false;

  AppStatus() {
    fetchChat();
  }

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

  void incOffset() {
    offset += offsetIncrement;
    notifyListeners();
  }

  void decOffset() {
    offset -= offsetIncrement;
    notifyListeners();
  }

  void fetchChat() async {
    ChatModel chat = ChatModel.fromJson(await AmqpInterface().retriveChat());
    streamer = chat.streamer;
    comments = chat.comments;
    fetchBadges();
    fetchBTTVEmotes();
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
          cheerEmotes != null &&
          cheerEmotes!.initialized();
    }
    return initStatus;
  }
}
