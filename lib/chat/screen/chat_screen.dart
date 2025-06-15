import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vertex_ai/chat/widgets/chat_input_field_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String response = '';

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
      body: SafeArea(
        child: Column(
          spacing: 20,
          children: [
            // Expanded(
            //   child: SingleChildScrollView(
            //     padding: const EdgeInsets.all(16),
            //     child: StreamBuilder<GenerateContentResponse>(
            //       stream: model.generateContentStream(prompt),
            //       builder: (context, snapshot) {
            //         if (snapshot.hasData) {
            //           response += snapshot.data!.text ?? '';
            //           return Text(response);
            //         } else if (snapshot.hasError) {
            //           return Text('Error: ${snapshot.error}');
            //         }
            //         return const CircularProgressIndicator();
            //       },
            //     ),
            //   ),
            // ),
            ChatInputField(onSend: (prompt) {}),
          ],
        ),
      ),
    );
  }
}
