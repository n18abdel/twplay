import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
}

void main() async {
  AmqpInterface interface = AmqpInterface();
  interface.setupLogSync();
}
