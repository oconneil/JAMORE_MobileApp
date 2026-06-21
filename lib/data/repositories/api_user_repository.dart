import '../../domain/entities/user_details.dart';
import '../../domain/repositories/repository_failure.dart';
import '../../domain/repositories/user_gateway.dart';
import '../../infrastructure/network/api_exception.dart';
import '../../infrastructure/network/jamore_api_client.dart';
import '../mappers/api_profile_mappers.dart';

class ApiUserRepository implements UserGateway {
  ApiUserRepository(this._apiClient);

  final JamoreApiClient _apiClient;
  final Map<String, Map<String, Object?>> _profilesById = {};

  @override
  Future<UserDetails> getUser(String userName) async {
    try {
      final response = await _apiClient.get(
        'User/GetUser/${Uri.encodeComponent(userName.trim())}',
      );
      final profile = ApiProfileMappers.userProfile(response);
      final user = ApiProfileMappers.userFromProfile(profile);
      if (user.id.isNotEmpty) _profilesById[user.id] = profile;
      return user;
    } on RepositoryFailure {
      rethrow;
    } on ApiException catch (error) {
      throw RepositoryFailure(error.message, cause: error);
    }
  }

  @override
  Future<UserDetails> updateDefaultLanguage({
    required UserDetails user,
    required String defaultLanguage,
  }) async {
    final profile = _profilesById[user.id];
    if (user.id.isEmpty || profile == null) {
      throw const RepositoryFailure('User profile is unavailable.');
    }

    final body = Map<String, Object?>.from(profile);
    _setField(body, 'defaultLanguage', defaultLanguage);
    try {
      final response = await _apiClient.post(
        'User/UpdateUserProfile/${Uri.encodeComponent(user.id)}',
        body: body,
      );
      final updatedProfile = ApiProfileMappers.userProfile(response);
      final updatedUser = ApiProfileMappers.userFromProfile(updatedProfile);
      _profilesById[user.id] = updatedProfile;
      return updatedUser;
    } on RepositoryFailure {
      rethrow;
    } on ApiException catch (error) {
      throw RepositoryFailure(error.message, cause: error);
    }
  }

  static void _setField(
    Map<String, Object?> profile,
    String name,
    Object? value,
  ) {
    final normalized = name.toLowerCase();
    final key = profile.keys.cast<String?>().firstWhere(
      (key) => key?.toLowerCase() == normalized,
      orElse: () => null,
    );
    profile[key ?? name] = value;
  }
}
