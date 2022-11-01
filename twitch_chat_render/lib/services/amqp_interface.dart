import 'dart:async';
import 'dart:convert';

import "package:dart_amqp/dart_amqp.dart";
import 'package:flutter/services.dart';

class AmqpInterface {
  static final Client client = Client();
  List<Consumer> consumers = [];

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
    consumers.add(consumer);
  }

  void setupSync(Map<String, Function> callbacks) async {
    callbacks.forEach((key, value) async {
      Channel channel = await client.channel();
      Exchange exchange =
          await channel.exchange("topic_chat", ExchangeType.TOPIC);
      Consumer consumer =
          await exchange.bindPrivateQueueConsumer(["sync.$key"]);
      consumer.listen((message) {
        double arg = double.parse(message.payloadAsString);
        callbacks[key]!(arg);
      });
      consumers.add(consumer);
    });
    setupExit();
  }

  void disposeSync() async {
    for (Consumer consumer in consumers) {
      await consumer.cancel();
    }
    consumers = [];
  }
}
