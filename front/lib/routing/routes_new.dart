abstract final class Routes {
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/';
  static const reset = '/reset-password';
  static const createPlan = '/create-plan';
  static const profil = '/profil';

  static const search = '/$searchRelative';
  static const searchRelative = 'search';
  static const results = '/$resultsRelative';
  static const resultsRelative = 'results';
  static const activities = '/$activitiesRelative';
  static const activitiesRelative = 'activities';
  static const booking = '/$bookingRelative';
  static const bookingRelative = 'booking';
  static String bookingWithId(int id) => '$booking/$id';
}
