import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message_model.dart';
import '../services/chat_repository.dart';
import '../services/encryption_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showEncrypted = false;

  @override
  void initState() {
    super.initState();
    EncryptionService.initialize();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Encrypt the message
    final encrypted = EncryptionService.encryptMessage(text);

    // Create message model
    final message = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderRole: 'user',
      ciphertext: encrypted.ciphertext,
      iv: encrypted.iv,
      timestamp: DateTime.now(),
    );

    // Save to Hive
    await ChatRepository.saveMessage(message);

    // Clear input
    _messageController.clear();

    // Scroll to bottom
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _decryptMessage(ChatMessageModel message) {
    try {
      return EncryptionService.decryptMessage(message.ciphertext, message.iv);
    } catch (e) {
      return 'Error decrypting message';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Chat'),
        actions: [
          IconButton(
            icon: Icon(_showEncrypted ? Icons.lock : Icons.lock_open),
            onPressed: () {
              setState(() {
                _showEncrypted = !_showEncrypted;
              });
            },
            tooltip: _showEncrypted ? 'Show Decrypted' : 'Show Encrypted',
          ),
        ],
      ),
      body: Column(
        children: [
          // Encrypted payload viewer (for demonstration)
          if (_showEncrypted)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.amber.shade50,
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Encrypted Mode: Showing ciphertext (E2EE demonstration)',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          
          // Messages list
          Expanded(
            child: FutureBuilder<Box<ChatMessageModel>>(
              future: ChatRepository.getBox(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final box = snapshot.data!;
                
                return ValueListenableBuilder(
                  valueListenable: box.listenable(),
                  builder: (context, _, __) {
                    final messages = box.values.toList()
                      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
                    
                    if (messages.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No messages yet.\nStart a conversation.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isUser = message.senderRole == 'user';
                        
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _showEncrypted 
                                    ? message.ciphertext.length > 50 
                                      ? message.ciphertext.substring(0, 50) + '...'
                                      : message.ciphertext
                                    : _decryptMessage(message),
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isUser ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

