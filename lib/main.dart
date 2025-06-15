import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vertex_ai/chat/bloc/chat_bloc.dart';
import 'package:flutter_vertex_ai/chat/model/chat_message_model.dart';
import 'package:flutter_vertex_ai/chat/repository/chat_repository.dart';

import 'firebase_options.dart';

// Initialize the Gemini Developer API backend service
// Create a `GenerativeModel` instance with a model that supports your use case
final model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.0-flash');

// Provide a prompt that contains text
final prompt = [Content.text('Write a story about a magic backpack.')];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    BlocProvider(
      create: (context) => ChatBloc(ChatRepository()),
      child: MaterialApp(home: const ChatScreen()),
    ),
  );
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(SendMessage(text));
    _controller.clear();
  }

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

      // body: SafeArea(
      //   child: Column(
      //     spacing: 20,
      //     children: [
      //       Expanded(
      //         child: SingleChildScrollView(
      //           padding: const EdgeInsets.all(16),
      //           child: StreamBuilder<GenerateContentResponse>(
      //             stream: model.generateContentStream(prompt),
      //             builder: (context, snapshot) {
      //               for (final Candidate candidate
      //                   in snapshot.data?.candidates ?? []) {
      //                 print(
      //                   'Text: ${candidate.text} Finish Reason: ${candidate.finishReason?.name} Length: ${snapshot.data?.candidates.length}',
      //                 );
      //                 print('Finish Message: ${candidate.finishMessage}');
      //               }
      //               print(
      //                 'Prompt Feedback: Blocked reason: ${snapshot.data?.promptFeedback?.blockReason}==== Blocked Message: ${snapshot.data?.promptFeedback?.blockReasonMessage}',
      //               );
      //               if (snapshot.hasData) {
      //                 response += snapshot.data!.text ?? '';
      //                 return Text(response);
      //               } else if (snapshot.hasError) {
      //                 return Text('Error: ${snapshot.error}');
      //               }
      //               return const CircularProgressIndicator();
      //             },
      //           ),
      //         ),
      //       ),
      //       Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      //         decoration: BoxDecoration(
      //           color: Colors.grey[100],
      //           borderRadius: BorderRadius.circular(24),
      //           boxShadow: [
      //             BoxShadow(
      //               color: Colors.black.withOpacity(0.05),
      //               blurRadius: 6,
      //               offset: const Offset(0, -1),
      //             ),
      //           ],
      //         ),
      //         child: Row(
      //           children: [
      //             Expanded(
      //               child: TextField(
      //                 controller: _controller,
      //                 textCapitalization: TextCapitalization.sentences,
      //                 decoration: const InputDecoration(
      //                   hintText: "Type a message",
      //                   border: InputBorder.none,
      //                 ),
      //               ),
      //             ),
      //             IconButton(
      //               icon: const Icon(Icons.send),
      //               color: Colors.indigoAccent,
      //               onPressed: () {},
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded || state is ContentCompleted) {
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  final messages = state is ChatLoaded
                      ? state.messages
                      : <ChatMessageModel>[];

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUser = message.role == Role.user;

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.indigoAccent
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Container(
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
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.indigoAccent,
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
