class AuthService {
  // Hardcoded credentials - change these to your preferred keys
  static const String _validUsername = 'elda';
  static const String _validPassword = '15032024';

  bool validateCredentials(String username, String password) {
    return username == _validUsername && password == _validPassword;
  }
}
