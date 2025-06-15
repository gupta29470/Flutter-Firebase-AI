part of 'chat_bloc.dart';

sealed class ChatEvent {
  const ChatEvent();
}

class SendMessage extends ChatEvent {
  final String prompt;

  const SendMessage(this.prompt);
}

class StreamContentFinished extends ChatEvent {}

class StreamContentError extends ChatEvent {
  final String error;

  const StreamContentError(this.error);
}