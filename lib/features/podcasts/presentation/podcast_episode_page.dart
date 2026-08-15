import 'package:flutter/material.dart';

import '../../../core/widgets/app_detail_page.dart';

/// Episode detail placeholder, reachable from [PodcastsPage] as
/// `/podcasts/:id`. The real podcast player is a dedicated later task.
class PodcastEpisodePage extends StatelessWidget {
  const PodcastEpisodePage({super.key, required this.episodeId});

  final String episodeId;

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      eyebrow: 'Podcasty',
      title: 'Odcinek $episodeId',
      icon: Icons.podcasts_rounded,
      description: 'Player odcinka pojawi się w kolejnym etapie developmentu.',
      fallbackLocation: '/podcasts',
    );
  }
}
