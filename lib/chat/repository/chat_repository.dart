import 'package:firebase_ai/firebase_ai.dart';

class ChatRepository {
  final gemini2Flash = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.0-flash',
  );

  Stream<GenerateContentResponse> generateContent(String prompt) {
    final promptList = [Content.text(prompt)];
    return gemini2Flash.generateContentStream(promptList);
  }
}
