import 'dart:async';

import "package:dart_amqp/dart_amqp.dart";

class AmqpInterface {
  final Client client = Client();

  Future<Map> retriveChat() async {
    final completer = Completer<Map>();

    Channel channel = await client.channel();
    Exchange exchange = await channel.exchange("chat", ExchangeType.FANOUT);
    Consumer consumer = await exchange.bindPrivateQueueConsumer(null);
    consumer.listen((message) {
      completer.complete(message.payloadAsJson);
      channel.close();
    });
    return completer.future;
  }
}

void main() async {
  AmqpInterface interface = AmqpInterface();
  Map chat = await interface.retriveChat();
  print(chat.keys);
  print(chat['comments'].length);
  print(chat['comments'][0]);
}
