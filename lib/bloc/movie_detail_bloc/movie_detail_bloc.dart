// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:movie_app/common/utils/enums/statuses.dart';
import 'package:movie_app/data/models/movie_detail/get_movie_detail_dto.dart';
import 'package:movie_app/data/repositories/movie_repo.dart';

part 'movie_detail_bloc.freezed.dart';
part 'movie_detail_event.dart';
part 'movie_detail_state.dart';

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  final MovieRepo movieRepo;
  MovieDetailBloc(this.movieRepo) : super(const MovieDetailState()) {
    on<_GetMovieDetails>((event, emit) async {
      try {
        emit(state.copyWith(status: Statuses.loading));

        final result = await movieRepo.getMovieDetails(
          movieId: event.movieId,
        );

        emit(state.copyWith(movieDetails: result, status: Statuses.success));
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
