import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/bloc/movie_bloc/movie_bloc.dart';
import 'package:movie_app/bloc/movie_bloc/movie_event.dart';
import 'package:movie_app/bloc/movie_bloc/movie_sate.dart';
import 'package:movie_app/bloc/movie_detail_bloc/movie_detail_bloc.dart';
import 'package:movie_app/presentation/screens/movie_dsetail_screen.dart';
import 'package:movie_app/presentation/widgets/custom_app_bar.dart';
import 'package:movie_app/presentation/widgets/custom_bottom_nav.dart';
import 'package:movie_app/presentation/widgets/filter_section.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0;

  void _onNavItemTapped(int index) {
    // setState(() {
    //   _currentIndex = index;
    // });
  }

  Future<void> _onRefresh() async {
    context.read<MovieBloc>().add(GetTopMovies());
  }

  Widget _buildShimmerSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 320,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        viewportFraction: 0.6,
      ),
      items: List.generate(3, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[900]!,
          highlightColor: Colors.grey[800]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<MovieBloc>().add(GetTopMovies());
    return Scaffold(
      backgroundColor: const Color(0xff0F1017),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(200),
        child: CustomAppBar(),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        backgroundColor: Colors.grey[900],
        color: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Filters",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      FilterSection(),
                      SizedBox(height: 22),
                    ]),
              ),
              BlocBuilder<MovieBloc, MovieSate>(
                bloc: context.read<MovieBloc>(),
                builder: (context, state) {
                  if (state is MovieLoading) {
                    return _buildShimmerSlider();
                  } else if (state is MovieSucces) {
                    final movies = state.movies;
                    return CarouselSlider(
                      options: CarouselOptions(
                        height: 320,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        enableInfiniteScroll: true,
                        viewportFraction: 0.6,
                      ),
                      items: movies.map((movie) {
                        return GestureDetector(
                          onTap: () {
                            context.read<MovieDetailBloc>().add(
                                MovieDetailEvent.getMovieDetails(
                                    movieId: int.parse(movie.id.toString())));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MovieDetailScreen(),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Hero(
                              tag: 'movie_image_${movie.id}',
                              child: Image.network(
                                "https://image.tmdb.org/t/p/w500${movie.posterPath}",
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return _buildShimmerSlider();
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}
