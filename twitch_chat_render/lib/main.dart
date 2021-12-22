import 'package:flutter/material.dart';
import 'package:twitch_chat_render/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twitch chat render',
      theme: ThemeData.dark(),
      home: const Home(),
    );
  }
}
