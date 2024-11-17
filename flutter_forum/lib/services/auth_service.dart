import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static User? currentUser;

  static Future<bool> register(String username, String password) async {
    // Generate a unique ID using UUID
    var uuid = Uuid();
    String userId = uuid.v4();

    final user = User(id: userId, username: username, password: password);
    await DatabaseService.registerUser(user);
    return true;
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
