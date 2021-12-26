import 'package:flutter/material.dart';

class AppStatus with ChangeNotifier {
  bool loaded = false;
  bool playing = false;
  double speed = 1;

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
}
