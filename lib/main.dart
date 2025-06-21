import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vertex_ai/chat/bloc/chat_bloc.dart';
import 'package:flutter_vertex_ai/chat/repository/chat_repository.dart';
import 'package:flutter_vertex_ai/chat/screen/chat_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    BlocProvider(
      create: (context) => ChatBloc(ChatRepository()),
      child: const MaterialApp(home: ChatScreen()),
    ),
  );
}
