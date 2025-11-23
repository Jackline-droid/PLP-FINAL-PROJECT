import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  // For demo purposes, using a static key stored in the app
  // In production, this should be derived from user credentials or stored securely
  static final String _demoKey = 'ThisIsADemoKey123456789012345678901234'; // 32 chars for AES-256
  
  static late final Key _key;
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;
    
    _key = Key.fromBase64(base64Encode(utf8.encode(_demoKey.padRight(32, '0').substring(0, 32))));
    _initialized = true;
  }

  /// Encrypt a message using AES-256
  static EncryptedMessage encryptMessage(String plaintext) {
    initialize();
    
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    
    return EncryptedMessage(
      ciphertext: encrypted.base64,
      iv: iv.base64,
    );
  }

  /// Decrypt a message using AES-256
  static String decryptMessage(String ciphertext, String ivBase64) {
    initialize();
    
    try {
      final iv = IV.fromBase64(ivBase64);
      final encrypter = Encrypter(AES(_key));
      final encrypted = Encrypted.fromBase64(ciphertext);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      
      return decrypted;
    } catch (e) {
      print('Decryption error: $e');
      return 'Error decrypting message';
    }
  }

  /// Generate a random IV for demonstration
  static String generateIV() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }
}

class EncryptedMessage {
  final String ciphertext;
  final String iv;

  EncryptedMessage({
    required this.ciphertext,
    required this.iv,
  });
}

