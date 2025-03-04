import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/bloc/movie_bloc/movie_bloc.dart';
import 'package:movie_app/bloc/movie_detail_bloc/movie_detail_bloc.dart';
import 'package:movie_app/bloc/movie_search_bloc/movie_search_bloc.dart';
import 'package:movie_app/data/repositories/movie_repo.dart';
import 'package:movie_app/main.dart';

void main() {
  late MovieRepo movieRepo;

  setUp(() {
    movieRepo = MovieRepo();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: movieRepo),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => MovieBloc(movieRepo),
            ),
            BlocProvider(
              create: (context) => MovieDetailBloc(movieRepo),
            ),
            BlocProvider(
              create: (context) => MovieSearchBloc(movieRepo),
            ),
          ],
          child: const MyApp(),
        ),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
