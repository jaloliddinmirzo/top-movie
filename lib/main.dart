import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/bloc/movie_bloc/movie_bloc.dart';
import 'package:movie_app/bloc/movie_detail_bloc/movie_detail_bloc.dart';
import 'package:movie_app/bloc/movie_search_bloc/movie_search_bloc.dart';
import 'package:movie_app/common/utils/bloc_obs.dart';
import 'package:movie_app/data/repositories/movie_repo.dart';
import 'package:movie_app/presentation/screens/home_screen.dart';

void main() {
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => MovieRepo(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => MovieBloc(context.read<MovieRepo>()),
          ),
          BlocProvider(
              create: (context) => MovieDetailBloc(context.read<MovieRepo>())),
          BlocProvider(
              create: (context) => MovieSearchBloc(context.read<MovieRepo>()))
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          title: 'Flutter Demo',
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
