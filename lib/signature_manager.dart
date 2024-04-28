import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';


class SignatureManager {

  static String sign(
    ECPrivateKey privateKey,
    String data,
  ) {
    final dataBytes = utf8.encode(data);
    final sign =
        CryptoUtils.ecSign(privateKey, dataBytes, algorithmName: 'SHA-256/ECDSA');

    final signature = CryptoUtils.ecSignatureToBase64(sign);

    return signature;
  }

  static bool verify(
    ECPublicKey publicKey,
    String sign,
    String data,
  ) {
    final dataBytes = utf8.encode(data);

    final ecSignature = CryptoUtils.ecSignatureFromBase64(sign);
    return CryptoUtils.ecVerify(publicKey, dataBytes, ecSignature, algorithm: 'SHA-256/ECDSA');
  }
}
