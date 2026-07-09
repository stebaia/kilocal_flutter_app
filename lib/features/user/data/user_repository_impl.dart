import 'package:dio/dio.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/graphql_client.dart';
import '../domain/app_user.dart';
import '../domain/user_details.dart';
import '../domain/user_repository.dart';
import 'dto/current_user_dto.dart';
import 'dto/user_details_dto.dart';
import 'user_api.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required UserApi userApi,
    required GraphqlClient graphqlClient,
  }) : _userApi = userApi,
       _graphqlClient = graphqlClient;

  final UserApi _userApi;
  final GraphqlClient _graphqlClient;

  static const _currentUserFields =
      'id,email,first_name,last_name,role.name,avatar';

  static const _getUserDetailsQuery = r'''
query GetUserDetails($myId: ID!) {
  user_details(filter: { user: { id: { _eq: $myId } } }) {
    id
    profile_status
    weight
    height
    gender
    newsletter
    allergie
    intolleranze
    dieta
    active_timeframe {
      id
      sort
    }
    percorso_integrazione_curr_phase {
      id
      sort
      translations {
        languages_code { code }
        title
      }
    }
    profile {
      id
      title
      main_color
      secondary_color
      icon { id }
      translations {
        languages_code { code }
        title
        name
        content
        content_f
      }
      kit {
        id
        price
        translations {
          languages_code { code }
          description
          tipo_kit
        }
      }
    }
  }
  user_addresses(filter: { user_created: { id: { _eq: $myId } } }) {
    id
    address
    city
    province
    zip
    phone
  }
}
''';

  @override
  Future<AppUser> fetchCurrentUser() async {
    try {
      final response = await _userApi.getCurrentUser(_currentUserFields);
      return _mapCurrentUser(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<UserDetails> fetchUserDetails(String myId) async {
    try {
      final result = await _graphqlClient.query(
        _getUserDetailsQuery,
        variables: <String, dynamic>{'myId': myId},
      );

      final data = result['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ApiException(
          type: ApiErrorType.unknown,
          statusCode: 200,
          message: 'Malformed GraphQL response: missing data',
        );
      }

      final detailsList = data['user_details'] as List<dynamic>?;
      if (detailsList == null || detailsList.isEmpty) {
        throw const ApiException(
          type: ApiErrorType.notFound,
          statusCode: 404,
          message: 'user_details not found',
        );
      }

      final detailsDto = UserDetailsDto.fromJson(
        detailsList.first as Map<String, dynamic>,
      );

      final addressesList = data['user_addresses'] as List<dynamic>?;
      final addressDtos = addressesList
          ?.map((e) => UserAddressDto.fromJson(e as Map<String, dynamic>))
          .toList();

      return detailsDto.toDomain(addresses: addressDtos);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> values) async {
    try {
      final response = await _userApi.updateProfile(values);
      if (!response.success) {
        throw const ApiException(
          type: ApiErrorType.unknown,
          statusCode: 200,
          message: 'Profile update reported success: false',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<String> updateAvatar({
    required List<int> imageBytes,
    required String filename,
  }) async {
    try {
      final file = MultipartFile.fromBytes(imageBytes, filename: filename);
      final upload = await _userApi.uploadFile(file);
      final fileId = upload.data.id;
      // `avatar` lives on `directus_users`; write it via PATCH /users/me. Using
      // PATCH /profile would route it to `user_details` and fail (500).
      await _userApi.updateCurrentUser(<String, dynamic>{'avatar': fileId});
      return fileId;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  AppUser _mapCurrentUser(CurrentUserDataDto dto) => AppUser(
    id: dto.id,
    email: dto.email,
    firstName: dto.firstName,
    lastName: dto.lastName,
    roleName: dto.role?.name,
    avatarUrl: dto.avatar != null
        ? '${Env.baseUrl}/assets/${dto.avatar}'
        : null,
  );
}
