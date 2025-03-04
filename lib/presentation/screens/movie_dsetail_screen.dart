import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/bloc/movie_detail_bloc/movie_detail_bloc.dart';
import 'package:movie_app/common/utils/enums/statuses.dart';
import 'package:movie_app/data/models/movie_detail/get_movie_detail_dto.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  YoutubePlayerController? _controller;
  int _selectedVideoIndex = 0;
  bool _isControllerInitialized = false;

  @override
  void dispose() {
    if (_isControllerInitialized && _controller != null) {
      _controller?.dispose();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
    super.dispose();
  }

  void _initializeController(String videoId) {
    if (!_isControllerInitialized) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          controlsVisibleAtStart: true,
          enableCaption: true,
          forceHD: true,
        ),
      )..addListener(_onPlayerStateChange);
      _isControllerInitialized = true;
    }
  }

  void _onPlayerStateChange() {
    if (_controller?.value.isFullScreen ?? false) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void _changeVideo(String videoId, int index) {
    if (_isControllerInitialized && _controller != null) {
      setState(() {
        _selectedVideoIndex = index;
        _controller?.load(videoId);
      });
    }
  }

  Widget _buildVideoPlayer() {
    if (!_isControllerInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      },
      onEnterFullScreen: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      },
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        onReady: () {
          setState(() {});
        },
        bottomActions: const [
          CurrentPosition(),
          ProgressBar(
            isExpanded: true,
            colors: ProgressBarColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
            ),
          ),
          RemainingDuration(),
          PlaybackSpeedButton(),
        ],
      ),
      builder: (context, player) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (_controller?.value.isFullScreen ?? false) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: player,
              );
            }
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: player,
            );
          },
        );
      },
    );
  }

  Widget _buildVideoInfo(MovieDetailResult video) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video.name ?? 'No Title',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (video.site != null)
            Row(
              children: [
                const Icon(Icons.play_circle_outline, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Platform: ${video.site}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          if (video.publishedAt != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Published: ${_formatDate(video.publishedAt!)}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildVideoList(List<MovieDetailResult> videos) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        final isSelected = index == _selectedVideoIndex;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey[900] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                "https://img.youtube.com/vi/${video.key}/0.jpg",
                width: 120,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 70,
                    color: Colors.grey[800],
                    child: const Icon(Icons.error_outline, color: Colors.white),
                  );
                },
              ),
            ),
            title: Text(
              video.name ?? 'No Title',
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "${video.site ?? 'Unknown'} • ${_formatDate(video.publishedAt ?? '')}",
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () => _changeVideo(video.key ?? '', index),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<MovieDetailBloc>().add(
                    const MovieDetailEvent.getMovieDetails(movieId: 0),
                  );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !(_controller?.value.isFullScreen ?? false),
      onPopInvoked: (didPop) {
        if (!didPop && (_controller?.value.isFullScreen ?? false)) {
          _controller?.toggleFullScreenMode();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xff0F1017),
        resizeToAvoidBottomInset: false,
        appBar: (_controller?.value.isFullScreen ?? false)
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
        body: BlocBuilder<MovieDetailBloc, MovieDetailState>(
          builder: (context, state) {
            switch (state.status) {
              case Statuses.loading:
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );

              case Statuses.success:
                final videos = state.movieDetails?.results ?? [];
                if (videos.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_off, color: Colors.grey, size: 48),
                        SizedBox(height: 16),
                        Text(
                          "No videos available",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                if (!_isControllerInitialized && videos[0].key != null) {
                  _initializeController(videos[0].key!);
                }

                return SafeArea(
                  left: !(_controller?.value.isFullScreen ?? false),
                  right: !(_controller?.value.isFullScreen ?? false),
                  bottom: !(_controller?.value.isFullScreen ?? false),
                  child: Column(
                    children: [
                      if (_controller?.value.isFullScreen ?? false)
                        Expanded(child: _buildVideoPlayer())
                      else
                        _buildVideoPlayer(),
                      if (!(_controller?.value.isFullScreen ?? false))
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildVideoList(videos),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );

              case Statuses.error:
                return _buildErrorView(
                    state.errorMessage ?? 'An error occurred');

              case Statuses.initial:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
