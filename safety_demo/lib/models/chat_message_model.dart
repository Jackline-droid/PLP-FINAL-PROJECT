import 'package:hive/hive.dart';

part 'chat_message_model.g.dart';

@HiveType(typeId: 1)
class ChatMessageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String senderRole; // 'user' or 'emergency_contact'

  @HiveField(2)
  final String ciphertext; // Encrypted message

  @HiveField(3)
  final String iv; // Initialization vector for decryption

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final bool isEncrypted; // Flag to indicate if message is encrypted

  ChatMessageModel({
    required this.id,
    required this.senderRole,
    required this.ciphertext,
    required this.iv,
    required this.timestamp,
    this.isEncrypted = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderRole': senderRole,
      'ciphertext': ciphertext,
      'iv': iv,
      'timestamp': timestamp.toIso8601String(),
      'isEncrypted': isEncrypted,
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      senderRole: json['senderRole'],
      ciphertext: json['ciphertext'],
      iv: json['iv'],
      timestamp: DateTime.parse(json['timestamp']),
      isEncrypted: json['isEncrypted'] ?? true,
    );
  }
}

