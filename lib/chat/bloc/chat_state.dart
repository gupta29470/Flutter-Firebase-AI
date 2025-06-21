part of 'chat_bloc.dart';

class ChatState {
  final ChatStateType type;
  final List<ChatMessageModel> messages;
  final String? errorMessage;

  const ChatState({
    this.type = ChatStateType.initial,
    List<ChatMessageModel>? messages,
    String? errorMessage,
  }) : messages = messages ?? const [],
       errorMessage = errorMessage ?? '';

  ChatState copyWith({
    ChatStateType? type,
    List<ChatMessageModel>? messages,
    String? errorMessage,
  }) {
    return ChatState(
      type: type ?? this.type,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum ChatStateType {
  initial,
  contentLoading,
  contentStreaming,
  contentError,
  loaded,
  error,
}
