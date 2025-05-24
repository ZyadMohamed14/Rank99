import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rank99/player_repo.dart';
import 'package:rank99/players_cubit.dart';
import 'package:rank99/ui/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://oibyiprtwwquxvixezwq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9pYnlpcHJ0d3dxdXh2aXhlendxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAyNDI4NzUsImV4cCI6MjA1NTgxODg3NX0.MqhcqRbyX48vy40pLgj_IkztCp1h75k9yj3yZJFt2S8',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Players',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => PlayersCubit(PlayersRepository()),
        child: const MainScreen(),
      ),
    );
  }
}