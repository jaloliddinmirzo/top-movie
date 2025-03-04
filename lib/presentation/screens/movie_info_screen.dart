import 'package:flutter/material.dart';
import 'package:movie_app/data/models/movie_serach/get_movie_search_dto.dart';
import 'package:shimmer/shimmer.dart';

class MovieInfoScreen extends StatelessWidget {
  final SearchResult movie;
  static const _backgroundColor = Color(0xff0F1017);

  const MovieInfoScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRatingAndReleaseDate(),
                    const SizedBox(height: 16),
                    _buildOverviewSection(),
                    const SizedBox(height: 16),
                    _buildAdditionalInformation(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: _backgroundColor,
      leading: const BackButton(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        title: Text(
          movie.title ?? "Noma'lum nom",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black,
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        background: _buildBackgroundImage(),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 300,
            color: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 24,
                  width: 120,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Container(
                  height: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildShimmerEffect();
      },
      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
    );
  }

  Widget _buildBackgroundImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'movie_image_${movie.id}',
          child: movie.backdropPath != null
              ? _buildNetworkImage(
                  'https://image.tmdb.org/t/p/original${movie.backdropPath}')
              : movie.posterPath != null
                  ? _buildNetworkImage(
                      'https://image.tmdb.org/t/p/w500${movie.posterPath}')
                  : _buildPlaceholderImage(),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black87,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(
          Icons.movie,
          color: Colors.white54,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildRatingAndReleaseDate() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: _buildRatingCard()),
          const SizedBox(width: 8),
          Expanded(child: _buildReleaseDateCard()),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    final hasRating = movie.voteAverage != null && movie.voteAverage! > 0;
    final rating = hasRating ? movie.voteAverage!.toStringAsFixed(1) : "N/A";
    final voteCount = movie.voteCount ?? 0;

    return Card(
      color: Colors.grey[900],
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: hasRating ? Colors.amber : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  rating,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (hasRating)
                  Text(
                    '/10',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$voteCount votes',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReleaseDateCard() {
    final hasDate = movie.releaseDate != null;
    final year = hasDate ? movie.releaseDate!.year.toString() : "N/A";

    return Card(
      color: Colors.grey[900],
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              color: hasDate ? Colors.white : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              year,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Release Year',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          movie.overview ?? "No overview available",
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.grey[300],
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildAdditionalInformation() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.grey[900],
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'Original Title',
                movie.originalTitle ?? "N/A",
              ),
              _buildInfoRow(
                'Language',
                movie.originalLanguage?.toUpperCase() ?? "N/A",
              ),
              _buildInfoRow(
                'Popularity',
                movie.popularity != null
                    ? '${movie.popularity!.toStringAsFixed(1)} points'
                    : "N/A",
              ),
              _buildInfoRow(
                'Adult Content',
                movie.adult == true ? 'Yes' : 'No',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.end,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
