import 'package:flutter/foundation.dart';
import 'package:dashboard/models/user.dart';
import 'package:dashboard/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<User> _users = [];
  User? _selectedUser;
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final fetchedUsers = await _userService.getUsers();
      _users = fetchedUsers;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchUserById(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _userService.getUserById(id);
      _selectedUser = user;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateUser(String id, User user) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedUser = await _userService.updateUser(id, user);

      // Update the user in the list
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = updatedUser;
      }

      _selectedUser = updatedUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeUserStatus(String id, bool isActive) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userService.changeUserStatus(id, isActive);

      // Update the user in the list
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isActive: isActive);
      }

      if (_selectedUser?.id == id) {
        _selectedUser = _selectedUser?.copyWith(isActive: isActive);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeUserRole(String id, String role) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userService.changeUserRole(id, role);

      // Update the user in the list
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(role: role);
      }

      if (_selectedUser?.id == id) {
        _selectedUser = _selectedUser?.copyWith(role: role);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setSelectedUser(User? user) {
    _selectedUser = user;
    notifyListeners();
  }
}
