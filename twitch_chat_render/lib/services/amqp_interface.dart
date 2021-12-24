import 'dart:async';
import 'dart:convert';

import "package:dart_amqp/dart_amqp.dart";
import 'package:flutter/services.dart';

class AmqpInterface {
  static final Client client = Client();

  Future<Map<String, dynamic>> retriveChat() async {
    final completer = Completer<Map<String, dynamic>>();

    Channel channel = await client.channel();
    Exchange exchange =
        await channel.exchange("topic_chat", ExchangeType.TOPIC);
    Consumer consumer = await exchange.bindPrivateQueueConsumer(["json"]);
    consumer.listen((message) {
      completer.complete(jsonDecode(message.payloadAsString));
      channel.close();
    });
    return completer.future;
  }

  void setupExit() async {
    Channel channel = await client.channel();
    Exchange exchange =
        await channel.exchange("topic_chat", ExchangeType.TOPIC);
    Consumer consumer = await exchange.bindPrivateQueueConsumer(["exit"]);
    consumer.listen((message) {
      client.close();
      SystemNavigator.pop();
    });
  }

  void setupSync(Map<String, Function> callbacks) async {
    Channel channel = await client.channel();
    Exchange exchange =
        await channel.exchange("topic_chat", ExchangeType.TOPIC);
    callbacks.forEach((key, value) async {
      Consumer consumer =
          await exchange.bindPrivateQueueConsumer(["sync.$key"]);
      consumer.listen((message) {
        double playerPosition = double.parse(message.payloadAsString);
        callbacks[key]!(playerPosition);
      });
    });
    setupExit();
  }
}
