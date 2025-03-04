part of 'movie_search_bloc.dart';

@freezed
class MovieSearchState with _$MovieSearchState {
  const factory MovieSearchState({
    @Default(Statuses.initial) Statuses status,
    GetMovieSearchDto? movieSearches,
    String? errorMessage,
  }) = _MovieSearchState;
}
