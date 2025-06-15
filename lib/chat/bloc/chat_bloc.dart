import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vertex_ai/chat/model/chat_message_model.dart';
import 'package:flutter_vertex_ai/chat/repository/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  ChatBloc(this._chatRepository) : super(const ChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<StreamContentFinished>(_onStreamContentFinished);
    on<StreamContentError>(_onStreamContentError);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    List<ChatMessageModel> messages = [];
    if (state is ChatLoaded) {
      messages = (state as ChatLoaded).messages;
    }

    final userMessage = ChatMessageModel(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      role: Role.user,
      content: event.prompt,
      timestamp: DateTime.now().toUtc(),
    );

    messages.add(userMessage);

    emit(ContentLoading());

    final aiMessage = ChatMessageModel(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      role: Role.ai,
      content: '',
      timestamp: DateTime.now(),
    );

    final Stream<GenerateContentResponse> stream = _chatRepository
        .generateContent(event.prompt);

    await for (final response in stream) {
      if (response.candidates.isNotEmpty) {
        for (final Candidate candidate in response.candidates) {
          final finishReason = candidate.finishReason;
          final text = candidate.text ?? '';
          messages.add(aiMessage);

          if (finishReason != null && finishReason != FinishReason.unknown) {
            final content = aiMessage.content + text;
            final updatedAiMessage = messages.last.copyWith(content: content);
            messages[messages.length - 1] = updatedAiMessage;
            emit(ChatLoaded(List.from(messages)));
          } else if (finishReason == FinishReason.stop) {
            add(StreamContentFinished());
          } else if (finishReason == FinishReason.maxTokens) {
            add(StreamContentError('Max Tokens reached'));
          } else if (finishReason == FinishReason.safety) {
            add(
              StreamContentError('Your message was blocked by safety filters'),
            );
          } else if (finishReason == FinishReason.other) {
            add(StreamContentError('An unknown error occurred'));
          }
        }
      }
    }
  }

  void _onStreamContentFinished(
    StreamContentFinished event,
    Emitter<ChatState> emit,
  ) {
    emit(ContentCompleted());
  }

  void _onStreamContentError(
    StreamContentError event,
    Emitter<ChatState> emit,
  ) {
    emit(ContentError(event.error));
  }
}
