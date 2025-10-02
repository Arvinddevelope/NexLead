import 'package:nextlead/data/models/user_model.dart';
import 'package:nextlead/data/services/user_service.dart';

class UserRepository {
  final UserService _userService;

  UserRepository(this._userService);

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    return await _userService.getUserByEmail(email);
  }

  /// Create a new user
  Future<User> createUser(String name, String email, String password) async {
    return await _userService.createUser(name, email, password);
  }

  /// Update user
  Future<User> updateUser(User user) async {
    return await _userService.updateUser(user);
  }
}
