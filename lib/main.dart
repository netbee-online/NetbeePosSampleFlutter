import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'key_manager.dart';
import 'signature_manager.dart';

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
  }

  @override
  void dispose() async {
    await socket?.close();

    super.dispose();
  }

  void messageReceived(Uint8List event) {
    try {
      final publicKey = KeyManager.netbeePublicKey;

      final message = utf8.decode(event).trim();
      setState(() {
        uiMessage = message;
      });

      final json = jsonDecode(message) as Map<String, dynamic>;

      final type = json["type"];
      switch (type) {
        case "payment_failed":
          final data = json["data"] as Map<String, dynamic>;
          final sign = data["sign"];
          final error = data["error"];
          final stanId = data["stan_id"];
          final payload = data["payload"] ?? "";
          final template = "#$error,$stanId,$payload#";

          final verified = SignatureManager.verify(publicKey, sign, template);

          if (verified) {
            setState(() {
              uiMessage = "payment failed and data verified. data: $data";
            });
          } else {
            setState(() {
              uiMessage = "payment failed and data didn't verify. data: $data";
            });
          }
          break;
        case "payment_success":
          final data = json["data"] as Map<String, dynamic>;
          final sign = data["sign"];
          final amount = data["amount"];
          final rrn = data["rrn"];
          final serial = data["serial"];
          final trace = data["trace"];
          final cardNumber = data["card_number"];
          final dateTime = data["datetime"];
          final stanId = data["stan_id"];
          final payload = data["payload"] ?? "";

          final template =
              "#$amount,$rrn,$serial,$trace,$cardNumber,$dateTime,$stanId,$payload#";

          final verified = SignatureManager.verify(publicKey, sign, template);

          if (verified) {
            setState(() {
              uiMessage = "payment success and data verified. data: $data";
            });
          } else {
            setState(() {
              uiMessage = "payment success but data didn't verify. data: $data";
            });
          }
          break;
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<void> startConnection() async {
    socket = await Socket.connect("127.0.0.1", 2448);
    socket?.listen(messageReceived);
  }

  Future<void> stopConnection() async {
    if (socket != null) {
      await socket!.close();
    }
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
                await stopConnection();
                await startConnection();

                final key = KeyManager.fakePrivateKey;
                const requestType = "payment_request";
                const amount = 2000;
                const payload = "id=1";
                const stanId = "29935e1e-634a-417c-95f9-437ae1c0f972";
                final sign =
                    SignatureManager.sign(key, "#$amount,$stanId,$payload#");

                final json = """
              { "type": "$requestType", "data": { "entity_type":"$requestType", "amount":$amount, "stan_id":"$stanId", "payload":"$payload", "sign": "$sign" } }
              """
                    .replaceAll("\n", "");

                if (socket == null) {
                  setState(() {
                    uiMessage = "socket is not connected!";
                  });
                } else {
                  socket!.write("$json\n");
                  socket!.flush();
                }
              },
              child: const Text("Send to POS"),
            ),
          ],
        ),
      ),
    );
  }
}
