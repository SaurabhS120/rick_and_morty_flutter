import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:rick_and_morty_flutter/model/character_model.dart';

class RickAndMortyRepoImpl {
  final Dio dio = Dio(BaseOptions(baseUrl: 'https://rickandmortyapi.com/api'));
  final Alice alice = Alice();
  RickAndMortyRepoImpl(){
    dio.interceptors.add(PrettyDioLogger());
    dio.interceptors.add(alice.getDioInterceptor());
  }
  
  Future<CharacterModel> getCharacters() async{
    var response =  await dio.get('/character');
    return CharacterModel.fromJson(response.data);
  }
}