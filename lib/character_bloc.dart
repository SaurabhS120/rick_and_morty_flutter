import 'package:alice/alice.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter/model/character_model.dart';
import 'package:rick_and_morty_flutter/repo/rick_and_morty_repo.dart';

class CharacterBloc extends Bloc<CharacterBlocEvent, CharacterBlocState> {
  final RickAndMortyRepo rickAndMortyRepo;
  final Alice alice;

  List<Result?> _results = [];
  bool _isLoading = false;

  String? _nextUrl;
  CharacterBloc({
    required this.rickAndMortyRepo,
    required this.alice,
  }) : super(CharacterBlocLoadingFirstPageState()) {
    on<CharacterBlocRefreshEvent>((event, emit) async {
      if (!_isLoading) {
        emit(CharacterBlocLoadingFirstPageState());
        _isLoading = true;
        try {
          var result = await rickAndMortyRepo.getCharacters();
          _isLoading = false;
          _nextUrl = result.info?.next;
          _results = result.results ?? [];
          alice.addLog(AliceLog(message: 'results count : ${_results.length}'));
          alice
              .addLog(AliceLog(message: 'total count : ${result.info?.count}'));
          emit(CharacterBlocSuccessPageState(
            results: result.results ?? [],
            info: result.info,
          ));
        } catch (e) {
          _isLoading = false;
          emit(CharacterBlocErrorState());
        }
      }
    });
    on<CharacterBlocFetchNextPageEvent>((event, emit) async {
      if (!_isLoading) {
        if (_nextUrl != null) {
          try {
            emit(CharacterBlocLoadingNextPageState(results: _results ?? []));
            _isLoading = true;
            var result = await rickAndMortyRepo.getCharactersByUrl(_nextUrl!);
            _nextUrl = result.info?.next;
            _results = [..._results, ...result.results ?? []];

            alice.addLog(
                AliceLog(message: 'results count : ${_results.length}'));
            alice.addLog(
                AliceLog(message: 'total count : ${result.info?.count}'));
            emit(CharacterBlocSuccessPageState(
              results: _results,
              info: result.info,
            ));
            _isLoading = false;
          } catch (e) {
            emit(CharacterBlocErrorState());
            _isLoading = false;
          }
        }
      }
    });
  }
}

class CharacterBlocEvent {}

class CharacterBlocRefreshEvent extends CharacterBlocEvent {}

class CharacterBlocFetchNextPageEvent extends CharacterBlocEvent {}

class CharacterBlocState {}

class CharacterBlocLoadingFirstPageState extends CharacterBlocState {}

class CharacterBlocLoadingNextPageState extends CharacterBlocState {
  List<Result?> results;
  CharacterBlocLoadingNextPageState({required this.results});
}

class CharacterBlocSuccessPageState extends CharacterBlocState {
  final Info? info;
  final List<Result?> results;
  CharacterBlocSuccessPageState({
    required this.info,
    required this.results,
  });
}

class CharacterBlocErrorState extends CharacterBlocState {}

class CharacterBlocErrorNextPageState extends CharacterBlocState {}
