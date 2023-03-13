import 'dart:async';
import 'dart:convert';

import "package:dart_amqp/dart_amqp.dart";

class AmqpInterface {
  static late final Client client;
  List<Consumer> consumers = [];

  Future<Map<String, dynamic>> retriveChat([String host = '']) async {
    client = host.isEmpty
        ? Client()
        : Client(settings: ConnectionSettings(host: host));
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

  void setupExit(Function callback) async {
    Channel channel = await client.channel();
    Exchange exchange =
        await channel.exchange("topic_chat", ExchangeType.TOPIC);
    Consumer consumer = await exchange.bindPrivateQueueConsumer(["exit"]);
    consumer.listen((message) {
      client.close();
      callback();
    });
    consumers.add(consumer);
  }

  void setupSync(Map<String, Function> callbacks, Function exitCallback) async {
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
    setupExit(exitCallback);
  }

  void disposeSync() async {
    for (Consumer consumer in consumers) {
      await consumer.cancel();
    }
    consumers = [];
  }
}
