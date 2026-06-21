import '../entities/user_details.dart';

abstract interface class UserGateway {
  Future<UserDetails> getUser(String userName);
}
