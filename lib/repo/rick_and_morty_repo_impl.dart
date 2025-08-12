import 'package:alice/alice.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:rick_and_morty_flutter/main.dart';
import 'package:rick_and_morty_flutter/model/character_model.dart';
import 'package:rick_and_morty_flutter/repo/rick_and_morty_repo.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

class RickAndMortyRepoImpl implements RickAndMortyRepo {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://rickandmortyapi.com/api'));
  RickAndMortyRepoImpl() {
    dio.interceptors.add(PrettyDioLogger());
    dio.interceptors.add(alice.getDioInterceptor());
    dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        if (response.statusCode == 200) {
          handler.next(response);
        } else {
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: 'Unexpected status code: ${response.statusCode}',
            ),
          );
        }
      },
    ));
    dio.interceptors.add(
      TalkerDioLogger(
        talker: talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseMessage: true,
        ),
      ),
    );
    dio.interceptors.add(ChuckerDioInterceptor());
  }

  @override
  Future<CharacterModel> getCharacters() async {
    var response = await dio.get('/character');
    return CharacterModel.fromJson(response.data);
  }

  @override
  Future<CharacterModel> getCharactersByUrl(String url) async {
    var response = await dio.get(url);
    return CharacterModel.fromJson(response.data);
  }
}
