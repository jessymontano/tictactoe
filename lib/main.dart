import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:tictactoe/logic/auth_controller.dart';
import 'package:tictactoe/logic/game_controller.dart';
import 'package:tictactoe/ui/screens/login.dart';
import 'package:tictactoe/ui/screens/lobby.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // iniciar db
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // si hay una sesión activa ir a la pantalla principal
          if (snapshot.hasData) {
            final User firebaseUser = snapshot.data!;

            context.read<AuthController>().loadCurrentSession(firebaseUser.uid);

            return const LobbyScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
