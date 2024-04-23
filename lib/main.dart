import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'key_manager.dart';
import 'signature.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Netbee POS Sample',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Socket? socket;

  String uiMessage = "waiting";

  @override
  void initState() {
    super.initState();
    startConnection();
  }

  @override
  void dispose() {
    super.dispose();
    socket?.close();
  }

  void messageReceived(Uint8List event) {
    try {
      final message = utf8.decode(event).trim();
      setState(() {
        uiMessage = message;
      });

      final json = jsonDecode(message) as Map<String, dynamic>;

      final type = json["type"];
      switch (type) {
        case "payment_failed":
          final publicKey = KeyManager.netbeePublicKey;

          final data = json["data"] as Map<String, dynamic>;
          final sign = data["sign"];
          final error = data["error"];
          final template = "#$error#";

          final verified = SignatureManager.verify(publicKey, sign, template);

          if (verified) {
            setState(() {
              uiMessage = "payment failed and data verified";
            });
          } else {
            setState(() {
              uiMessage = "payment failed and data didn't verify";
            });
          }
          break;
        case "payment_success":
          final publicKey = KeyManager.fakePublicKey;

          final data = json["data"] as Map<String, dynamic>;
          final sign = data["sign"];
          final amount = data["amount"];
          final rrn = data["rrn"];
          final serial = data["serial"];
          final trace = data["trace"];
          final cardNumber = data["card_number"];
          final dateTime = data["datetime"];
          final payload = data["payload"];

          final template =
              "#$amount,$rrn,$serial,$trace,$cardNumber,$dateTime,$payload#";

          final verified = SignatureManager.verify(publicKey, sign, template);

          if (verified) {
            setState(() {
              uiMessage = "payment failed and data verified";
            });
          } else {
            setState(() {
              uiMessage = "payment failed and data didn't verify";
            });
          }
          break;
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  void startConnection() async {
    socket = await Socket.connect("127.0.0.1", 2448);
    socket?.listen(messageReceived);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Netbee POS Sample"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(uiMessage),
            ElevatedButton(
              onPressed: () async {
                final key = KeyManager.fakePrivateKey;
                const requestType = "payment_request";
                const amount = 1000;
                const payload = "id=1";
                final sign = SignatureManager.sign(key, "#$amount,$payload#");

                final json = """
              { "type": "$requestType", "data": { "entity_type":"$requestType", "amount":$amount, "payload":"$payload", "sign": "$sign" } }
              """
                    .replaceAll("\n", "");
                socket?.write("$json\n");
              },
              child: const Text("Send to POS"),
            ),
          ],
        ),
      ),
    );
  }
}
