class ApiConstants {
  static const String baseUrl = 'https://pawffy-backend.onrender.com';

  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String me = '/api/auth/me';
  static const String updateMe = '/api/users/me';
  static const String vets = '/api/vets';
  static const String notifications = '/api/notifications';
  static const String markAllNotificationsRead = '/api/notifications/read-all';

  static String markNotificationRead(String id) =>
      '/api/notifications/$id/read';

  static String deleteNotification(String id) => '/api/notifications/$id';
  static const String pets = '/api/pets';
  static String petById(String id) => '/api/pets/$id';
}
