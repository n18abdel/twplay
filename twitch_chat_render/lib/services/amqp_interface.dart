import 'dart:async';
import 'dart:convert';

import "package:dart_amqp/dart_amqp.dart";

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

  void setupLogSync() async {
    Channel channel = await client.channel();
    Exchange exchange =
        await channel.exchange("topic_chat", ExchangeType.TOPIC);
    Consumer consumer = await exchange.bindPrivateQueueConsumer(["sync.#"]);
    consumer.listen((message) {
      print("${message.routingKey} - ${message.payloadAsString}");
    });
  }

  void setupSync(Map<String, Function> callbacks) async {
    Channel channel = await client.channel();
    Exchange exchange =
        await channel.exchange("topic_chat", ExchangeType.TOPIC);
    Consumer consumerPlay =
        await exchange.bindPrivateQueueConsumer(["sync.play"]);
    Consumer consumerPause =
        await exchange.bindPrivateQueueConsumer(["sync.pause"]);
    Consumer consumerTimer =
        await exchange.bindPrivateQueueConsumer(["sync.timer"]);
    consumerPlay.listen((message) {
      double playerPosition = double.parse(message.payloadAsString);
      callbacks["play"]!(playerPosition);
    });
    consumerPause.listen((message) {
      callbacks["pause"]!();
    });
    consumerTimer.listen((message) {
      double playerPosition = double.parse(message.payloadAsString);
      callbacks["timer"]!(playerPosition);
    });
  }
}

void main() async {
  AmqpInterface interface = AmqpInterface();
  interface.setupLogSync();
}
