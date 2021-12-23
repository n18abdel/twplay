import 'dart:async';
import 'dart:convert';

import "package:dart_amqp/dart_amqp.dart";

class AmqpInterface {
  final Client client = Client();

  Future<Map<String, dynamic>> retriveChat() async {
    final completer = Completer<Map<String, dynamic>>();

    Channel channel = await client.channel();
    Exchange exchange = await channel.exchange("chat", ExchangeType.FANOUT);
    Consumer consumer = await exchange.bindPrivateQueueConsumer(null);
    consumer.listen((message) {
      completer.complete(jsonDecode(message.payloadAsString));
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
