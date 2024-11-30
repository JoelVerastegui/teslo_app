import 'package:dio/dio.dart';
import 'package:teslo_shop/config/config.dart';
import 'package:teslo_shop/features/auth/domain/domain.dart';
import 'package:teslo_shop/features/auth/infrastructure/infrastructure.dart';

class AuthDatasourceImpl extends AuthDatasource{
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl
    )
  );

  @override
  Future<User> checkAuthStatus(String token) {
    // TODO: implement checkAuth
    throw UnimplementedError();
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password
      });

      final user = UserMapper.userJsonToEntity(response.data);

      return user;
    } on DioException catch (e) {
      if(e.response?.statusCode == 401) throw WrongCredentials;

      if(e.type == DioExceptionType.connectionTimeout) throw ConnectionTimeout;

      throw CustomError('Custom error exception', '1');
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<User> register(String email, String password, String fullname) async {
    try {
      final json = await dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'fullName': fullname
      });

      final user = UserMapper.userJsonToEntity(json.data);

      return user;
    } on DioException catch (e) {
      if(e.response?.statusCode == 401) throw WrongCredentials;
      if(e.type == DioExceptionType.connectionTimeout) throw ConnectionTimeout;
      throw CustomError('Custom error: ${e.message}','Status code: ${e.response?.statusCode}');
    } catch (e) {
      throw Exception();
    }
  }

}