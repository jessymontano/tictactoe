import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/logic/auth_controller.dart';
import 'package:tictactoe/logic/game_controller.dart';
import 'package:tictactoe/ui/screens/login.dart';
import 'package:tictactoe/ui/screens/lobby.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase manejando el error de duplicado
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print(' Firebase initialized successfully');
  } catch (e) {
    if (e.toString().contains('duplicate-app') ||
        e.toString().contains('[DEFAULT]')) {
      print(
        ' Firebase already initialized. Continuing with existing instance.',
      );
      // No hacemos nada, solo continuamos
    } else {
      print(' Unexpected error: $e');
      rethrow;
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => GameController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            final User firebaseUser = snapshot.data!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.read<AuthController>().loadCurrentSession(
                  firebaseUser.uid,
                );
              }
            });
            return const LobbyScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
