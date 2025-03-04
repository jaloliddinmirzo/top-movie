// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:movie_app/common/utils/enums/statuses.dart';
import 'package:movie_app/data/models/movie_serach/get_movie_search_dto.dart';
import 'package:movie_app/data/repositories/movie_repo.dart';

part 'movie_search_bloc.freezed.dart';
part 'movie_search_event.dart';
part 'movie_search_state.dart';

class MovieSearchBloc extends Bloc<MovieSearchEvent, MovieSearchState> {
  final MovieRepo movieRepo;
  MovieSearchBloc(this.movieRepo) : super(const MovieSearchState()) {
    on<_GetMovieSearch>((event, emit) async {
      try {
        emit(state.copyWith(status: Statuses.loading));

        final result =
            await movieRepo.getMovieSearchByTitle(title: event.title);
        log("Keldi search $result");
        emit(state.copyWith(movieSearches: result, status: Statuses.success));
      } catch (e) {
        emit(
          state.copyWith(
            errorMessage: e.toString(),
            status: Statuses.error,
          ),
        );
      }
    });
  }
}
