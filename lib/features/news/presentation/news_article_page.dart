import 'package:flutter/material.dart';

import '../../../core/widgets/app_detail_page.dart';

/// Article detail placeholder, reachable from [NewsPage] as `/news/:slug`.
/// Demonstrates that a branch can host a detail route above the main list
/// while keeping the bottom navigation visible — the real article content
/// arrives with the WordPress REST API integration.
class NewsArticlePage extends StatelessWidget {
  const NewsArticlePage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      eyebrow: 'Newsy',
      title: slug.replaceAll('-', ' '),
      icon: Icons.article_outlined,
      description:
          'Treść artykułu „$slug” pojawi się po podłączeniu WordPress REST API.',
      fallbackLocation: '/news',
    );
  }
}
