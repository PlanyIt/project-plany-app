import 'user.dart';

extension UserExtensions on User {
  int get getFollowersCount => followersCount ?? followers.length;
  int get getFollowingCount => followingCount ?? following.length;
}
