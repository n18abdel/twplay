import 'package:flutter/material.dart';

class AppStatus with ChangeNotifier {
  bool loaded = false;
  bool playing = false;
  double speed = 1;
  double offset = 0;
  static const double offsetIncrement = 0.5;

  void didLoad() {
    loaded = true;
    notifyListeners();
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
}
