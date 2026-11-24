import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/ai_service.dart';

// --- DATA MODEL ---
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isStreaming;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isStreaming = false,
  });

  ChatMessage copyWith({String? text, bool? isStreaming}) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      isUser: isUser,
      timestamp: timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

// --- RIVERPOD PROVIDERS ---
final aiServiceProvider = Provider<AiService>((ref) => AiService());

final apiKeyProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(aiServiceProvider);
  return await service.getApiKey();
});

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isStreaming;

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.isStreaming = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isStreaming,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  StreamSubscription<String>? _streamSub;

  @override
  ChatState build() {
    ref.onDispose(() {
      _streamSub?.cancel();
    });

    return ChatState(
      messages: [
        ChatMessage(
          id: 'init_welcome',
          text: 'Halo! Saya Campus AI Assistant 🎓. Ada yang bisa saya bantu terkait jadwal, beasiswa, atau informasi akademik kampus hari ini?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || state.isStreaming || state.isLoading) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final botMessageId = '${DateTime.now().millisecondsSinceEpoch}_bot';
    final initialBotMessage = ChatMessage(
      id: botMessageId,
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    state = state.copyWith(
      messages: [...state.messages, initialBotMessage],
      isLoading: false,
      isStreaming: true,
    );

    final aiService = ref.read(aiServiceProvider);
    _streamSub?.cancel();
    _streamSub = aiService
        .askStream(query)
        .listen(
          (chunk) {
            final updatedMessages = state.messages.map((msg) {
              if (msg.id == botMessageId) {
                return msg.copyWith(text: chunk, isStreaming: true);
              }
              return msg;
            }).toList();

            state = state.copyWith(messages: updatedMessages);
          },
          onDone: () {
            final finalizedMessages = state.messages.map((msg) {
              if (msg.id == botMessageId) {
                return msg.copyWith(isStreaming: false);
              }
              return msg;
            }).toList();

            state = state.copyWith(
              messages: finalizedMessages,
              isStreaming: false,
            );
          },
          onError: (err) {
            final errorMessages = state.messages.map((msg) {
              if (msg.id == botMessageId) {
                return msg.copyWith(
                  text: 'Terjadi kesalahan: $err',
                  isStreaming: false,
                );
              }
              return msg;
            }).toList();

            state = state.copyWith(
              messages: errorMessages,
              isStreaming: false,
              isLoading: false,
            );
          },
        );
  }

  void clearChat() {
    state = ChatState(
      messages: [
        ChatMessage(
          id: 'init_welcome_cleared',
          text: 'Riwayat percakapan telah dibersihkan. Silakan ajukan pertanyaan baru seputar kampus.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }
}

final chatNotifierProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

// --- UI CHAT SCREEN ---
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickPrompts = [
    '📅 Jadwal kampus hari Senin?',
    '🎓 Info pendaftaran beasiswa',
    '📚 Jam buka perpustakaan pusat',
    '📍 Lokasi gedung jurusan TI',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _showApiKeyDialog(BuildContext context, String? currentKey) {
    final controller = TextEditingController(text: currentKey ?? '');
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.key, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text(
              'Pengaturan AI API Key',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan Google Gemini API Key Anda. Kunci ini disimpan secara aman menggunakan FlutterSecureStorage.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.security),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '🔒 Catatan Privasi: NIK dan Nomor HP otomatis disensor sebelum dikirim ke API.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          if (currentKey != null && currentKey.isNotEmpty)
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await ref.read(aiServiceProvider).clearApiKey();
                ref.invalidate(apiKeyProvider);
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'API Key berhasil dihapus (Mode Simulasi aktif).',
                    ),
                  ),
                );
              },
              child: const Text(
                'Hapus Kunci',
                style: TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final newKey = controller.text.trim();
              if (newKey.isNotEmpty) {
                final messenger = ScaffoldMessenger.of(context);
                await ref.read(aiServiceProvider).saveApiKey(newKey);
                ref.invalidate(apiKeyProvider);
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('API Key berhasil disimpan dengan aman!'),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final apiKeyAsync = ref.watch(apiKeyProvider);

    ref.listen<ChatState>(chatNotifierProvider, (_, next) {
      _scrollToBottom();
    });

    final hasApiKey = apiKeyAsync.maybeWhen(
      data: (key) => key != null && key.isNotEmpty,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campus AI Assistant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: hasApiKey ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  hasApiKey
                      ? 'Gemini 1.5 Flash • Terhubung'
                      : 'Mode Simulasi (Kunci Belum Diatur)',
                  style: TextStyle(
                    fontSize: 11,
                    color: hasApiKey ? Colors.green[700] : Colors.orange[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            tooltip: 'Bersihkan Riwayat',
            onPressed: () {
              ref.read(chatNotifierProvider.notifier).clearChat();
            },
          ),
          IconButton(
            icon: Icon(
              hasApiKey ? Icons.key : Icons.key_off,
              color: hasApiKey ? Colors.blueAccent : Colors.orange,
            ),
            tooltip: 'Pengaturan API Key',
            onPressed: () {
              final currentKey = apiKeyAsync.asData?.value;
              _showApiKeyDialog(context, currentKey);
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF7F9FC),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount:
                    chatState.messages.length + (chatState.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == chatState.messages.length &&
                      chatState.isLoading) {
                    return _buildLoadingBubble();
                  }
                  final message = chatState.messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            if (!chatState.isStreaming && !chatState.isLoading)
              Container(
                height: 42,
                margin: const EdgeInsets.only(bottom: 6),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _quickPrompts.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    return ActionChip(
                      backgroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.blue.shade100),
                      ),
                      label: Text(
                        _quickPrompts[i],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      onPressed: () {
                        _inputController.text = _quickPrompts[i];
                        _handleSend();
                      },
                    );
                  },
                ),
              ),
            _buildInputBar(chatState.isStreaming || chatState.isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final timeStr =
        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade700,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? Colors.blueAccent : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text.isEmpty && message.isStreaming
                        ? '...'
                        : message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: isUser ? Colors.white70 : Colors.black38,
                          fontSize: 10,
                        ),
                      ),
                      if (message.isStreaming) ...[
                        const SizedBox(width: 6),
                        const SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.deepPurple.shade400,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.shade700,
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Asisten sedang merespons...',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isBusy) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.document_scanner_outlined,
                        size: 20,
                        color: Colors.blueAccent,
                      ),
                      tooltip: 'Scan Dokumen (OCR)',
                      onPressed: isBusy ? null : _handleOcrScan,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.mic_none_outlined,
                        size: 20,
                        color: Colors.deepPurple,
                      ),
                      tooltip: 'Input Suara (Speech-to-Text)',
                      onPressed: isBusy ? null : _handleSpeechInput,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        enabled: !isBusy,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSend(),
                        decoration: const InputDecoration(
                          hintText: 'Tulis pertanyaan...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.black45,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 22,
              backgroundColor: isBusy ? Colors.grey : Colors.blueAccent,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: isBusy ? null : _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend() {
    final text = _inputController.text;
    if (text.trim().isNotEmpty) {
      _inputController.clear();
      ref.read(chatNotifierProvider.notifier).sendMessage(text);
    }
  }

  Future<void> _handleOcrScan() async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Memindai dokumen melalui OCR...'),
        duration: Duration(seconds: 1),
      ),
    );
    final ocrText = await ref
        .read(aiServiceProvider)
        .recognizeText('dokumen_kampus.jpg');
    setState(() {
      _inputController.text = ocrText;
    });
  }

  Future<void> _handleSpeechInput() async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Mendengarkan input suara (Speech-to-Text)...'),
        duration: Duration(seconds: 1),
      ),
    );
    final spokenText = await ref
        .read(aiServiceProvider)
        .speechToText('audio_input.wav');
    setState(() {
      _inputController.text = spokenText;
    });
  }
}
