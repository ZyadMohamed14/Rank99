import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rank99/player_repo.dart';
import 'package:rank99/players_cubit.dart';
import 'package:rank99/ui/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vbrdswbpanduhhehbjnt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZicmRzd2JwYW5kdWhoZWhiam50Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4Mzg2MTksImV4cCI6MjA3MDQxNDYxOX0.ObxmtgNsD6f3IluiMyx8E15nhdY7ua6GGM3a1pjHD6w', // Replace with your Supabase anon key
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Football Playders',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => PlayersCubit(PlayersRepository()),
        child: const MainScreen(),
      ),
    );
  }
}