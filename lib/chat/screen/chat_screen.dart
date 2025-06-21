import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vertex_ai/chat/bloc/chat_bloc.dart';
import 'package:flutter_vertex_ai/chat/model/chat_message_model.dart';
import 'package:flutter_vertex_ai/chat/widgets/chat_input_field_widget.dart';
import 'package:flutter_vertex_ai/extensions/string_extension.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gemini Example',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
      ),

      body: const _ChatBodyWidget(),
    );
  }
}

class _ChatBodyWidget extends StatefulWidget {
  const _ChatBodyWidget();

  @override
  State<_ChatBodyWidget> createState() => _ChatBodyWidgetState();
}

class _ChatBodyWidgetState extends State<_ChatBodyWidget> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _listener(ChatState state) {
    if (state.type == ChatStateType.loaded) {
      _scrollToBottom();
    } else if (state.type == ChatStateType.error ||
        state.type == ChatStateType.contentError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                _listener(state);
              },
              buildWhen: (previous, current) {
                if (current.type == ChatStateType.loaded) {
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                final messages = state.type == ChatStateType.loaded
                    ? state.messages
                    : <ChatMessageModel>[];

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUser = message.role == Role.user;

                    return _ChatMessageWidget(isUser: isUser, message: message);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          const ChatSendWidget(),
        ],
      ),
    );
  }
}

class _ChatMessageWidget extends StatelessWidget {
  final bool isUser;
  final ChatMessageModel message;

  const _ChatMessageWidget({required this.isUser, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.indigoAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: isUser
            ? Text(message.content, style: const TextStyle(color: Colors.white))
            : Text.rich(message.content.parseBoldText()),
      ),
    );
  }
}
