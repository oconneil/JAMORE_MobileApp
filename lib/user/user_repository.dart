import '../network/jamore_api_client.dart';
import 'user_models.dart';

abstract interface class UserGateway {
  Future<UserDetails> getUser(String userName);
}

class UserRepository implements UserGateway {
  UserRepository(this._apiClient);

  final JamoreApiClient _apiClient;

  @override
  Future<UserDetails> getUser(String userName) async {
    final encodedUserName = Uri.encodeComponent(userName.trim());

    final response = await _apiClient.get('User/GetUser/$encodedUserName');
    return UserDetails.fromApiResponse(response);
  }
}
