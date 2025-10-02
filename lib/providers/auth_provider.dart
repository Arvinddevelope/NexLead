import 'package:flutter/material.dart';
import 'package:nextlead/data/models/user_model.dart';
import 'package:nextlead/data/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _userName = '';
  String _userEmail = '';
  User? _currentUser;
  late UserRepository _userRepository;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get userEmail => _userEmail;
  User? get currentUser => _currentUser;
  UserRepository get userRepository => _userRepository; // Expose userRepository

  AuthProvider(UserRepository userRepository) {
    _userRepository = userRepository;
    _checkSavedSession();
  }

  /// Check for saved session on app startup
  Future<void> _checkSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    final savedName = prefs.getString('user_name');

    if (savedEmail != null && savedName != null) {
      _isLoggedIn = true;
      _userEmail = savedEmail;
      _userName = savedName;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get user from Airtable
      final user = await _userRepository.getUserByEmail(email);

      if (user != null && user.password == password) {
        // Valid credentials
        _isLoggedIn = true;
        _currentUser = user;
        _userEmail = user.email;
        _userName = user.name;

        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', user.email);
        await prefs.setString('user_name', user.name);
      } else {
        throw Exception('Invalid email or password');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user already exists
      final existingUser = await _userRepository.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('User with this email already exists');
      }

      // Create new user in Airtable
      final now = DateTime.now();
      final newUser = User(
        id: '', // Will be assigned by Airtable
        name: name,
        email: email,
        password: password, // Note: In a real app, this should be hashed
        createdAt: now,
        updatedAt: now,
      );

      _currentUser = await _userRepository.createUser(name, email, password);
      _isLoggedIn = true;
      _userName = _currentUser!.name;
      _userEmail = _currentUser!.email;

      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', _currentUser!.email);
      await prefs.setString('user_name', _currentUser!.name);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear session
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_name');

      // Reset all values
      _isLoggedIn = false;
      _userName = '';
      _userEmail = '';
      _currentUser = null;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if a user exists by email
  Future<bool> userExists(String email) async {
    try {
      final user = await _userRepository.getUserByEmail(email);
      return user != null;
    } catch (e) {
      return false;
    }
  }
}
