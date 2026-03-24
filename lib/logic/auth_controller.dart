import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:tictactoe/data/models/user_model.dart';
import 'package:tictactoe/data/services/auth_service.dart';

// manejador de estado para autenticación
class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;

  UserModel? get currentUser => _user;

  Future<bool> register(String email, String password, String username) async {
    UserModel? user = await _authService.registerUser(
      email,
      password,
      username,
    );

    if (user != null) {
      _user = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    UserModel? user = await _authService.login(email, password);

    if (user != null) {
      _user = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> loadCurrentSession(String uid) async {
    UserModel? user = await _authService.getUserData(uid);
    if (user != null) {
      _user = user;
      notifyListeners();
    }
  }

  Future<bool> updatePfp(File imageFile) async {
    if (_user == null) return false;

    String? newImageUrl = await _authService.uploadPfp(_user!.uid, imageFile);

    if (newImageUrl != null) {
      _user = UserModel(
        uid: _user!.uid,
        username: _user!.username,
        email: _user!.email,
        pfpUrl: newImageUrl,
      );

      notifyListeners();
      return true;
    }
    return false;
  }
}
