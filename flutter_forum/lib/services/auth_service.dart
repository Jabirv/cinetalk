import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static User? currentUser;

  static Future<bool> register(String username, String password) async {
    final user = User(username: username, password: password);
    final userId = await DatabaseService.registerUser(user);
    return userId > 0;
  }

  static Future<bool> login(String username, String password) async {
    final user = await DatabaseService.loginUser(username, password);
    if (user != null) {
      currentUser = user;
      print('Logged in as: ${currentUser?.username}, id: ${currentUser?.id}');
      return true;
    }
    print('Failed to log in');
    return false;
  }
}

