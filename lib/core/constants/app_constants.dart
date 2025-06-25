class AppConstants {
  static const String appName = 'Cuent AI';
  static const String welcomeMessage = 'Bienvenido de vuelta';
  static const String loginSubtitle = 'Inicia sesión para continuar';
  static const String registerTitle = 'Crear cuenta';
  static const String registerSubtitle = 'Únete a nuestra comunidad';

  // API Constants
  static const String baseUrl =
      'https://cuent-ai-core-326160083778.us-central1.run.app/api/v1';
  static const String loginEndpoint = '/users/sign-in';
  static const String registerEndpoint = '/users/sign-up';
  static const String projectsEndpoint = '/projects';
  static const String scriptsEndpoint = '/scripts';
  static const String assetsEndpoint = '/assets';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
