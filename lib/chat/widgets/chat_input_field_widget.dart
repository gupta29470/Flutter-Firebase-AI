import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vertex_ai/chat/bloc/chat_bloc.dart';

class ChatSendWidget extends StatefulWidget {
  const ChatSendWidget({super.key});

  @override
  State<ChatSendWidget> createState() => _ChatSendWidgetState();
}

class _ChatSendWidgetState extends State<ChatSendWidget> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(SendMessage(text));
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: "Type a message",
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.type == ChatStateType.contentLoading
                      ? Icons.stop
                      : Icons.send,
                ),
                color: Colors.indigoAccent,
                onPressed: state.type == ChatStateType.contentLoading
                    ? () {
                        context.read<ChatBloc>().add(StreamContentFinished());
                        _controller.clear();
                      }
                    : _sendMessage,
              );
            },
          ),
        ],
      ),
    );
  }
}
