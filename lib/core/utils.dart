import 'dart:math';

// generar código aleatorio para las salas de juego
String createLobbyCode({int length = 5}) {
  const String characters = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  Random random = Random();

  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => characters.codeUnitAt(random.nextInt(characters.length)),
    ),
  );
}
