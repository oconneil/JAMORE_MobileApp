import '../../domain/entities/user_details.dart';
import '../../domain/repositories/repository_failure.dart';
import '../../domain/repositories/user_gateway.dart';
import '../../infrastructure/network/api_exception.dart';
import '../../infrastructure/network/jamore_api_client.dart';
import '../mappers/api_profile_mappers.dart';

class ApiUserRepository implements UserGateway {
  ApiUserRepository(this._apiClient);

  final JamoreApiClient _apiClient;

  @override
  Future<UserDetails> getUser(String userName) async {
    try {
      final response = await _apiClient.get(
        'User/GetUser/${Uri.encodeComponent(userName.trim())}',
      );
      return ApiProfileMappers.user(response);
    } on RepositoryFailure {
      rethrow;
    } on ApiException catch (error) {
      throw RepositoryFailure(error.message, cause: error);
    }
  }
}
