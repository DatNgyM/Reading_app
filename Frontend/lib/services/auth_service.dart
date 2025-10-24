import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  
  // Danh sách người dùng mặc định
  static final List<User> _defaultUsers = [
    User(
      id: 'admin_001',
      username: 'admin',
      email: 'admin@readingapp.com',
      password: 'admin123',
      role: 'admin',
      createdAt: DateTime.now(),
    ),
    User(
      id: 'user_001',
      username: 'user',
      email: 'user@readingapp.com',
      password: 'user123',
      role: 'user',
      createdAt: DateTime.now(),
    ),
  ];

  // Lưu danh sách người dùng
  static Future<void> _saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((user) => user.toJson()).toList();
    await prefs.setString(_usersKey, jsonEncode(usersJson));
  }

  // Lấy danh sách người dùng
  static Future<List<User>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString(_usersKey);
    
    if (usersString == null) {
      // Nếu chưa có dữ liệu, tạo danh sách mặc định
      await _saveUsers(_defaultUsers);
      return _defaultUsers;
    }
    
    final List<dynamic> usersJson = jsonDecode(usersString);
    return usersJson.map((json) => User.fromJson(json)).toList();
  }

  // Lưu người dùng hiện tại
  static Future<void> _saveCurrentUser(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    } else {
      await prefs.remove(_currentUserKey);
    }
  }

  // Lấy người dùng hiện tại
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_currentUserKey);
    
    if (userString == null) return null;
    
    try {
      final userJson = jsonDecode(userString);
      return User.fromJson(userJson);
    } catch (e) {
      return null;
    }
  }

  // Đăng nhập
  static Future<AuthResult> login(String username, String password) async {
    try {
      final users = await _getUsers();
      
      // Tìm người dùng theo username hoặc email
      final user = users.firstWhere(
        (u) => (u.username == username || u.email == username) && u.password == password,
        orElse: () => throw Exception('Không tìm thấy người dùng'),
      );

      if (!user.isActive) {
        return AuthResult.error('Tài khoản đã bị khóa');
      }

      // Cập nhật thời gian đăng nhập cuối
      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
      final updatedUsers = users.map((u) => u.id == user.id ? updatedUser : u).toList();
      await _saveUsers(updatedUsers);
      await _saveCurrentUser(updatedUser);

      return AuthResult.success(updatedUser);
    } catch (e) {
      return AuthResult.error('Tên đăng nhập hoặc mật khẩu không đúng');
    }
  }

  // Đăng ký
  static Future<AuthResult> register(String username, String email, String password, String confirmPassword) async {
    try {
      // Kiểm tra mật khẩu
      if (password != confirmPassword) {
        return AuthResult.error('Mật khẩu xác nhận không khớp');
      }

      if (password.length < 6) {
        return AuthResult.error('Mật khẩu phải có ít nhất 6 ký tự');
      }

      // Kiểm tra email hợp lệ
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        return AuthResult.error('Email không hợp lệ');
      }

      final users = await _getUsers();

      // Kiểm tra username đã tồn tại
      if (users.any((u) => u.username == username)) {
        return AuthResult.error('Tên đăng nhập đã tồn tại');
      }

      // Kiểm tra email đã tồn tại
      if (users.any((u) => u.email == email)) {
        return AuthResult.error('Email đã được sử dụng');
      }

      // Tạo người dùng mới
      final newUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        email: email,
        password: password,
        role: 'user', // Mặc định là user
        createdAt: DateTime.now(),
      );

      users.add(newUser);
      await _saveUsers(users);
      await _saveCurrentUser(newUser);

      return AuthResult.success(newUser);
    } catch (e) {
      return AuthResult.error('Có lỗi xảy ra khi đăng ký: ${e.toString()}');
    }
  }

  // Đăng xuất
  static Future<void> logout() async {
    await _saveCurrentUser(null);
  }

  // Lấy danh sách tất cả người dùng (chỉ admin)
  static Future<List<User>> getAllUsers() async {
    return await _getUsers();
  }

  // Cập nhật trạng thái người dùng (chỉ admin)
  static Future<bool> updateUserStatus(String userId, bool isActive) async {
    try {
      final users = await _getUsers();
      final userIndex = users.indexWhere((u) => u.id == userId);
      
      if (userIndex == -1) return false;
      
      users[userIndex] = users[userIndex].copyWith(isActive: isActive);
      await _saveUsers(users);
      
      // Nếu đang cập nhật user hiện tại, cập nhật luôn
      final currentUser = await getCurrentUser();
      if (currentUser?.id == userId) {
        await _saveCurrentUser(users[userIndex]);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Kiểm tra quyền admin
  static Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.isAdmin ?? false;
  }
}

class AuthResult {
  final bool success;
  final String? error;
  final User? user;

  AuthResult.success(this.user) : success = true, error = null;
  AuthResult.error(this.error) : success = false, user = null;
}
