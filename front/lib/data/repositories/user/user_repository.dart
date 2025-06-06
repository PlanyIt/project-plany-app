import 'package:front/domain/models/user.dart';
import 'package:front/utils/result.dart';

/// Data source for user related data
abstract class UserRepository {
  /// Get current user
  Future<Result<User>> getUser();
}
