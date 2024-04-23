import 'package:basic_utils/basic_utils.dart';

class KeyManager {
  // TODO("generate or replace these with yours")

  static const _fakePrivateKeyString = "-----BEGIN PRIVATE KEY-----\nMIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgecauuASSa4zrQ7q7OtVOjtVZVsfxPr5Yx/TggDdW0HWhRANCAARKn+TtijxV9FvGGWSzQua9tLXIQ/MX97X6G/EWQaso0seq4lkmkLkAD4dtWptUaUCe/lxdfiDlmct3Ydq80wRq\n-----END PRIVATE KEY-----";

  static const _fakePublicKeyString = "-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAESp/k7Yo8VfRbxhlks0LmvbS1yEPzF/e1+hvxFkGrKNLHquJZJpC5AA+HbVqbVGlAnv5cXX4g5ZnLd2HavNMEag==\n-----END PUBLIC KEY-----";

  static const _netbeePublicKeyString = "-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEjWrmg+dm7+Kk0cX3PJcP7OMv8KalJfvcWvrf6O2wXaNaD0BK3htCMszWhy3uAc9Wyudtq49sM9P7oPELaDhJwA==\n-----END PUBLIC KEY-----";

  static final fakePublicKey =
      CryptoUtils.ecPublicKeyFromPem(_fakePublicKeyString);

  static final fakePrivateKey =
      CryptoUtils.ecPrivateKeyFromPem(_fakePrivateKeyString);

  static final netbeePublicKey =
      CryptoUtils.ecPublicKeyFromPem(_netbeePublicKeyString);
}
