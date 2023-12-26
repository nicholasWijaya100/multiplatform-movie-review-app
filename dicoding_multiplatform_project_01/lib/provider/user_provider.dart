import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  Map<String, Map<String, String>> _users = {};
  String? _currentUserName;
  String? _currentUserEmail;

  bool register(String name, String email, String password) {
    if (_users.containsKey(email)) {
      return false; // Pengguna sudah ada
    } else {
      _users[email] = {
        'name': name,
        'password': password
      };
      notifyListeners();
      return true; // Pendaftaran berhasil
    }
  }

  bool login(String email, String password) {
    if (_users.containsKey(email) && _users[email]?['password'] == password) {
      _currentUserEmail = email;
      _currentUserName = _users[email]?['name'];
      notifyListeners();
      return true; // Login sukses
    }
    return false; // Login gagal
  }

  // Metode untuk mendapatkan email pengguna saat ini
  String? getCurrentUserEmail() {
    return _currentUserEmail;
  }

  // Metode untuk mendapatkan nama pengguna saat ini
  String? getCurrentUserName() {
    return _currentUserName;
  }
}
