import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediora/Network/networkServices.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    _connectWebSocket();
    _loadCurrentUser();
    _loadHistory();
    _listenToMessages();
  }

  Future<void> _connectWebSocket() async {
    await ChatServices().connectToChat();
    ChatServices().ping();
  }

  Future<void> _loadCurrentUser() async {
    final id = await _secureStorage.read(key: 'user_id');
    print('Loaded user_id: $id');
    if (mounted) setState(() => _currentUserId = id);
  }

  Future<void> _loadHistory() async {
    if (widget.conversationId == null) {
      if (mounted) setState(() => _isLoadingHistory = false);
      return;
    }

    final data = await ChatServices().getConversationMessages(
      widget.conversationId!,
    );

    if (!mounted) return;

    if (data.isEmpty) {
      setState(() => _isLoadingHistory = false);
      return;
    }

    final List<_ChatMessage> history = data.reversed.map((item) {
      final msg = item as Map<String, dynamic>;
      final String senderId = msg['sender_id']?.toString() ?? '';
      final bool isMe = senderId == _currentUserId;
      final String body = msg['body']?.toString() ?? '';
      final String createdAt = msg['created_at']?.toString() ?? '';
      final String messageId =
          msg['id']?.toString() ?? '';
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

    _scrollToBottom();
  }

  void _listenToMessages() {
    _subscription = ChatServices().messageStream?.listen((data) {
      if (!mounted) return;
      try {
        final json = jsonDecode(data as String) as Map<String, dynamic>;
        final String type = json['type']?.toString() ?? '';
        print('WebSocket received type: $type');
        print('WebSocket received full: $json');

        if (type == 'message.sent') {
          final payload = json['payload'] as Map<String, dynamic>? ?? json;

          final String convId = payload['conversation_id']?.toString() ?? '';
          if (widget.conversationId != null && convId != widget.conversationId)
            return;

          final String senderId = payload['sender_id']?.toString() ?? '';
          final bool isMe = senderId == _currentUserId;
          final String body = payload['body']?.toString() ?? '';
          final String createdAt = payload['created_at']?.toString() ?? '';
          final String messageId =
              payload['message_id']?.toString() ??
              payload['id']?.toString() ??
              '';

          final bool alreadyExists = _messages.any(
            (m) => m.text == body && m.isMe,
          );
          if (isMe && alreadyExists) return;

          setState(() {
            _isDoctorTyping = false;
            _messages.add(
              _ChatMessage(
                id: messageId,
                text: body,
                isMe: isMe,
                time: createdAt.isNotEmpty
                    ? _formatTime(createdAt)
                    : _currentTime(),
                isRead: false,
              ),
            );
          });

          if (!isMe && widget.conversationId != null) {
            ChatServices().sendReadReceipt(
              conversationId: widget.conversationId!,
              messageId: messageId,
            );
          }
          _scrollToBottom();
        } else if (type == 'message.typing') {
          final payload = json['payload'] as Map<String, dynamic>? ?? json;
          final String userId = payload['user_id']?.toString() ?? '';
          if (userId != _currentUserId) {
            setState(() => _isDoctorTyping = true);
            _typingTimer?.cancel();
            _typingTimer = Timer(const Duration(seconds: 3), () {
              if (mounted) setState(() => _isDoctorTyping = false);
            });
          }
        } else if (type == 'message.read') {
          final payload = json['payload'] as Map<String, dynamic>? ?? json;
          final String messageId = payload['message_id']?.toString() ?? '';
          setState(() {
            final index = _messages.indexWhere((m) => m.id == messageId);
            if (index != -1) {
              _messages[index] = _messages[index].copyWith(isRead: true);
            }
          });
        } else if (type == 'ping') {
          print('WebSocket: pong received ✅');
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
      _messages.add(
        _ChatMessage(
          id: '',
          text: text,
          isMe: true,
          time: _currentTime(),
          isRead: false,
        ),
      );
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
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F6FA),
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
          size: 28.r,
          color: isDark ? Colors.white70 : const Color(0xFF555B72),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          _buildAvatar(radius: 20.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              _displayName,
              style: TextStyle(
                fontSize: 15.sp,
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
          onTap: () {
            final TextEditingController nameController =
                TextEditingController();
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
                title: Text(
                  'Rename Conversation',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1D23),
                  ),
                ),
                content: TextField(
                  controller: nameController,
                  autofocus: true,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A1D23),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter new name',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : const Color(0xFF999EAE),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white24
                            : const Color(0xFFEBEBEB),
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4C6EF5)),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final newName = nameController.text.trim();
                      if (newName.isEmpty) return;
                      Navigator.pop(ctx);
                      final success = await ChatServices().modifyConversation(
                        widget.conversationId!,
                        name: newName,
                      );
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Conversation renamed successfully'),
                            backgroundColor: Color(0xFF4C6EF5),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Color(0xFF4C6EF5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          isDark: isDark,
        ),
        SizedBox(width: 8.w),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(0.5.h),
        child: Container(
          color: isDark ? Colors.white12 : const Color(0xFFEBEBEB),
          height: 0.5.h,
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
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4C6EF5)),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      itemCount: _messages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return const _DateDivider(label: 'Today');
        final msg = _messages[index - 1];
        return _MessageBubble(
          message: msg,
          isDark: isDark,
          senderAvatar: _buildAvatar(radius: 13.r),
        );
      },
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, bottom: 4.h),
      child: Row(
        children: [
          _buildAvatar(radius: 13.r),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'typing...',
              style: TextStyle(
                fontSize: 12.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isDark ? Colors.white12 : const Color(0xFFEBEBEB),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: _onTextChanged,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.white : const Color(0xFF1A1D23),
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Type a message…',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : const Color(0xFF999EAE),
                      fontSize: 13.sp,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: 4,
                  minLines: 1,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF4C6EF5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4C6EF5).withOpacity(0.35),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 16.r,
                ),
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
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[senderAvatar, SizedBox(width: 6.w)],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: message.isMe
                    ? const Color(0xFF4C6EF5)
                    : isDark
                    ? const Color(0xFF2A2A2A)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(message.isMe ? 18.r : 5.r),
                  bottomRight: Radius.circular(message.isMe ? 5.r : 18.r),
                ),
                boxShadow: message.isMe
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4.r,
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: message.isMe
                          ? Colors.white
                          : isDark
                          ? Colors.white
                          : const Color(0xFF1A1D23),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.time,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: message.isMe
                              ? Colors.white.withOpacity(0.65)
                              : const Color(0xFF999EAE),
                        ),
                      ),
                      if (message.isMe) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.done_all_rounded,
                          size: 14.r,
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
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
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
  const _AppBarIconBtn({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.h,
        margin: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F2F8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16.r,
          color: isDark ? Colors.white70 : const Color(0xFF555B72),
        ),
      ),
    );
  }
}
