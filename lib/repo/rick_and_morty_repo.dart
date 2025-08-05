import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:rick_and_morty_flutter/model/character_model.dart';

abstract class RickAndMortyRepo {
  Future<CharacterModel> getCharacters();
  Future<CharacterModel> getCharactersByUrl(String url);
}