part of 'chat_bloc.dart';

sealed class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ContentLoading extends ChatState {
  const ContentLoading();
}

class ContentStreaming extends ChatState {
  final String response;

  const ContentStreaming(this.response);
}

class ContentCompleted extends ChatState {
  const ContentCompleted();
}

class ContentError extends ChatState {
  final String error;

  const ContentError(this.error);
}

class ChatLoaded extends ChatState {
  final List<ChatMessageModel> messages;

  const ChatLoaded(this.messages);
}

class ChatError extends ChatState {
  final String error;

  const ChatError(this.error);
}
