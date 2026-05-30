import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediora/Network/networkServices.dart';

class ChatPage extends StatefulWidget {
  final String firstName;
  final String? lastName;
  final String doctorId;
  final String? conversationId;
  final String? avatarUrl;

  const ChatPage({
    super.key,
    required this.firstName,
    this.lastName,
    required this.doctorId,
    this.conversationId,
    this.avatarUrl,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final List<_ChatMessage> _messages = [];
  StreamSubscription? _subscription;
  String? _currentUserId;
  bool _isLoadingHistory = true;
  bool _isDoctorTyping = false;
  Timer? _typingTimer;

  String get _displayName {
    final last = widget.lastName;
    if (last != null && last.isNotEmpty) return '${widget.firstName} $last';
    return widget.firstName;
  }

  String get _initials {
    final first = widget.firstName.trim();
    final last = widget.lastName?.trim() ?? '';
    if (last.isNotEmpty) return '${first[0]}${last[0]}'.toUpperCase();
    if (first.length >= 2) return first.substring(0, 2).toUpperCase();
    return first[0].toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadHistory();
    _listenToMessages();
  }

  Future<void> _loadCurrentUser() async {
    final id = await _secureStorage.read(key: 'user_id');
    if (mounted) setState(() => _currentUserId = id);
  }

  Future<void> _loadHistory() async {
    if (widget.conversationId == null) {
      if (mounted) setState(() => _isLoadingHistory = false);
      return;
    }
    final data = await ChatServices().getConversationMessages(widget.conversationId!);
    if (!mounted) return;

    final List<_ChatMessage> history = data.map((item) {
      final msg = item as Map<String, dynamic>;
      final String senderId = msg['sender_id']?.toString() ?? '';
      final bool isMe = senderId == _currentUserId;
      final String body = msg['body']?.toString() ?? '';
      final String createdAt = msg['created_at']?.toString() ?? '';
      final String messageId = msg['message_id']?.toString() ?? '';
      return _ChatMessage(
        id: messageId,
        text: body,
        isMe: isMe,
        time: _formatTime(createdAt),
        isRead: false,
      );
    }).toList();

    setState(() {
      _messages.addAll(history);
      _isLoadingHistory = false;
    });

    if (history.isNotEmpty && widget.conversationId != null) {
      ChatServices().sendReadReceipt(
        conversationId: widget.conversationId!,
        messageId: history.last.id,
      );
    }

    _scrollToBottom();
  }

  void _listenToMessages() {
    _subscription = ChatServices().messageStream?.listen((data) {
      if (!mounted) return;
      try {
        final json = jsonDecode(data as String) as Map<String, dynamic>;
        final String type = json['type']?.toString() ?? '';

        if (type == 'message') {
          final String convId = json['conv_id']?.toString() ?? '';
          if (widget.conversationId != null && convId != widget.conversationId) return;

          final String senderId = json['sender_id']?.toString() ?? '';
          final bool isMe = senderId == _currentUserId;
          final String body = json['body']?.toString() ?? '';
          final String createdAt = json['created_at']?.toString() ?? '';
          final String messageId = json['message_id']?.toString() ?? '';

          setState(() {
            _isDoctorTyping = false;
            _messages.add(_ChatMessage(
              id: messageId,
              text: body,
              isMe: isMe,
              time: _formatTime(createdAt),
              isRead: false,
            ));
          });

          if (!isMe && widget.conversationId != null) {
            ChatServices().sendReadReceipt(
              conversationId: widget.conversationId!,
              messageId: messageId,
            );
          }

          _scrollToBottom();
        } else if (type == 'typing') {
          final String userId = json['user_id']?.toString() ?? '';
          if (userId != _currentUserId) {
            setState(() => _isDoctorTyping = true);
            _typingTimer?.cancel();
            _typingTimer = Timer(const Duration(seconds: 3), () {
              if (mounted) setState(() => _isDoctorTyping = false);
            });
          }
        } else if (type == 'read') {
          final String messageId = json['message_id']?.toString() ?? '';
          setState(() {
            final index = _messages.indexWhere((m) => m.id == messageId);
            if (index != -1) {
              _messages[index] = _messages[index].copyWith(isRead: true);
            }
          });
        }
      } catch (e) {
        print('WebSocket parse error: $e');
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.conversationId == null) return;

    setState(() {
      _messages.add(_ChatMessage(
        id: '',
        text: text,
        isMe: true,
        time: _currentTime(),
        isRead: false,
      ));
    });

    _controller.clear();
    _scrollToBottom();

    ChatServices().sendMessage(
      conversationId: widget.conversationId!,
      message: text,
    );
  }

  void _onTextChanged(String value) {
    if (widget.conversationId == null) return;
    ChatServices().sendTyping(conversationId: widget.conversationId!);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  String _formatTime(String isoString) {
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return '';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _typingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA),
      appBar: _buildAppBar(context, isDark),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList(isDark)),
          if (_isDoctorTyping) _buildTypingIndicator(isDark),
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(
          Icons.chevron_left_rounded,
          size: 28,
          color: isDark ? Colors.white70 : const Color(0xFF555B72),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          _buildAvatar(radius: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _displayName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1D23),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        _AppBarIconBtn(
          icon: Icons.more_vert_rounded,
          onTap: () {},
          isDark: isDark,
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          color: isDark ? Colors.white12 : const Color(0xFFEBEBEB),
          height: 0.5,
        ),
      ),
    );
  }

  Widget _buildAvatar({required double radius}) {
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(widget.avatarUrl!),
        onBackgroundImageError: (_, __) {},
        backgroundColor: const Color(0xFF4C6EF5),
        child: null,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF4C6EF5),
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.55,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMessagesList(bool isDark) {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4C6EF5)));
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      itemCount: _messages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return const _DateDivider(label: 'Today');
        final msg = _messages[index - 1];
        return _MessageBubble(
          message: msg,
          isDark: isDark,
          senderAvatar: _buildAvatar(radius: 13),
        );
      },
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        children: [
          _buildAvatar(radius: 13),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'typing...',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white12 : const Color(0xFFEBEBEB),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: _onTextChanged,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white : const Color(0xFF1A1D23),
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Type a message…',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : const Color(0xFF999EAE),
                      fontSize: 13,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: 4,
                  minLines: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF4C6EF5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4C6EF5).withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final String time;
  final bool isRead;

  const _ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    required this.isRead,
  });

  _ChatMessage copyWith({bool? isRead}) => _ChatMessage(
        id: id,
        text: text,
        isMe: isMe,
        time: time,
        isRead: isRead ?? this.isRead,
      );
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final bool isDark;
  final Widget senderAvatar;

  const _MessageBubble({
    required this.message,
    required this.isDark,
    required this.senderAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            senderAvatar,
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: message.isMe
                    ? const Color(0xFF4C6EF5)
                    : isDark
                        ? const Color(0xFF2A2A2A)
                        : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isMe ? 18 : 5),
                  bottomRight: Radius.circular(message.isMe ? 5 : 18),
                ),
                boxShadow: message.isMe
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: message.isMe
                          ? Colors.white
                          : isDark
                              ? Colors.white
                              : const Color(0xFF1A1D23),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.time,
                        style: TextStyle(
                          fontSize: 10,
                          color: message.isMe
                              ? Colors.white.withOpacity(0.65)
                              : const Color(0xFF999EAE),
                        ),
                      ),
                      if (message.isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: message.isRead
                              ? Colors.lightBlueAccent
                              : Colors.white.withOpacity(0.65),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  final String label;
  const _DateDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF999EAE),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _AppBarIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _AppBarIconBtn({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F2F8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white70 : const Color(0xFF555B72),
        ),
      ),
    );
  }
}