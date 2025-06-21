import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vertex_ai/chat/model/chat_message_model.dart';
import 'package:flutter_vertex_ai/chat/repository/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  bool _isStreamCancelled = false;

  ChatBloc(this._chatRepository) : super(const ChatState()) {
    on<SendMessage>(_onSendMessage);
    on<StreamContentFinished>(_onStreamContentFinished);
    on<StreamContentError>(_onStreamContentError);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    List<ChatMessageModel> messages = List.from(state.messages);

    final userMessage = ChatMessageModel(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      role: Role.user,
      content: event.prompt,
      timestamp: DateTime.now().toUtc(),
    );

    messages.add(userMessage);

    emit(
      state.copyWith(type: ChatStateType.loaded, messages: List.from(messages)),
    );

    await Future.delayed(const Duration(milliseconds: 100));

    emit(state.copyWith(type: ChatStateType.contentLoading));

    final aiMessage = ChatMessageModel(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      role: Role.ai,
      content: '',
      timestamp: DateTime.now(),
    );

    messages.add(aiMessage);

    String updatedAiMessage = "";

    final Stream<GenerateContentResponse> stream = _chatRepository
        .generateContent(event.prompt);

    await for (final response in stream) {
      if (_isStreamCancelled) break;
      if (response.candidates.isNotEmpty) {
        for (final Candidate candidate in response.candidates) {
          final finishReason = candidate.finishReason;
          updatedAiMessage += candidate.text ?? '';

          final updatedAiMessageModel = messages.last.copyWith(
            content: updatedAiMessage,
          );
          messages[messages.length - 1] = updatedAiMessageModel;
          emit(
            state.copyWith(
              type: ChatStateType.loaded,
              messages: List.from(messages),
            ),
          );

          if (finishReason == FinishReason.stop) {
            add(StreamContentFinished());
          } else if (finishReason == FinishReason.maxTokens) {
            add(const StreamContentError('Max Tokens reached'));
          } else if (finishReason == FinishReason.safety) {
            add(
              const StreamContentError(
                'Your message was blocked by safety filters',
              ),
            );
          } else if (finishReason == FinishReason.other) {
            add(const StreamContentError('An unknown error occurred'));
          }
        }
      }
    }

    if (_isStreamCancelled) {
      _isStreamCancelled = false;
    }
  }

  void _onStreamContentFinished(
    StreamContentFinished event,
    Emitter<ChatState> emit,
  ) {
    _isStreamCancelled = true;
    emit(state.copyWith(type: ChatStateType.loaded));
  }

  void _onStreamContentError(
    StreamContentError event,
    Emitter<ChatState> emit,
  ) {
    emit(
      state.copyWith(
        type: ChatStateType.contentError,
        errorMessage: event.error,
      ),
    );
  }
}
