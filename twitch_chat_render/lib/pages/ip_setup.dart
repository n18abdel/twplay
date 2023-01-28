import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_chat_render/models/app_status.dart';

class IpSetupPage extends StatefulWidget {
  const IpSetupPage({Key? key}) : super(key: key);

  @override
  State<IpSetupPage> createState() => _IpSetupPageState();
}

class _IpSetupPageState extends State<IpSetupPage> {
  String ip = "";

  void submit(BuildContext context) {
    context.read<AppStatus>().setAmqpHost(ip);
    Navigator.pushReplacementNamed(context, "/loading");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter your server host/IP',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid host/IP';
                }
                return null;
              },
              onChanged: (value) => {ip = value},
              onFieldSubmitted: (value) => submit(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () => submit(context),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
