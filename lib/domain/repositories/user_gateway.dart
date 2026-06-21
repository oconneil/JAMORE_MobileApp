import '../entities/user_details.dart';

abstract interface class UserGateway {
  Future<UserDetails> getUser(String userName);

  Future<UserDetails> updateDefaultLanguage({
    required UserDetails user,
    required String defaultLanguage,
  });
}
