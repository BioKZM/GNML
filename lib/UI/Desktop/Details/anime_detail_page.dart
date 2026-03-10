import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Logic/animepage_logic.dart';
import 'package:vault/Providers/library_provider.dart';
import 'package:vault/Helper/content_type.dart';

class AnimeDetailPage extends StatefulWidget {
  final int animeId;

  const AnimeDetailPage({super.key, required this.animeId});

  @override
  State<AnimeDetailPage> createState() => _AnimeDetailPageState();
}

class _AnimeDetailPageState extends State<AnimeDetailPage> {
  final AnimePageLogic _logic = AnimePageLogic();

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeProvider>(context).color;

    return FutureBuilder(
      future: _logic.getAnimeDetails(widget.animeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Skeletonizer(
            enabled: true,
            child: Scaffold(
              backgroundColor: const Color(0xFF121212),
              appBar: AppBar(
                backgroundColor: Colors.black,
                title: const Text('Loading'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Loading title'),
                    const SizedBox(height: 8),
                    const Text('Loading subtitle'),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: 6,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return Container(
                            height: 18,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
              child: Text('Anime not found',
                  style: TextStyle(color: Colors.white)),
            ),
          );
        }

        return Consumer<LibraryProvider>(
          builder: (context, libraryProvider, child) {
            final inLibrary = libraryProvider.isInLibrary(
              ContentType.anime,
              widget.animeId,
            );

            final animeMap = {
              "id": widget.animeId,
              "type": "anime",
              "title": data.title,
              "imageURL": data.imageURL,
              "folder": "library",
            };

            return Scaffold(
              backgroundColor: const Color(0xFF121212),
              appBar: AppBar(
                backgroundColor: Colors.black,
                title: Text(data.title ?? 'Anime'),
                actions: [
                  IconButton(
                    onPressed: () {
                      if (inLibrary) {
                        libraryProvider.removeFromLibrary(
                          ContentType.anime,
                          widget.animeId,
                        );
                      } else {
                        libraryProvider.addOrUpdateItem(
                          type: ContentType.anime,
                          id: widget.animeId,
                          title: data.title,
                          imageUrl: data.imageURL,
                          extra: animeMap,
                        );
                      }
                    },
                    icon: Icon(
                      inLibrary ? Icons.favorite : Icons.favorite_outline,
                      color: inLibrary ? Color(themeColor) : Colors.white,
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data.imageURL != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              data.imageURL!,
                              width: 220,
                              height: 320,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.title ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _InfoChip(
                                    label: 'Score',
                                    value:
                                        data.score?.toStringAsFixed(1) ?? '-',
                                    color: Color(themeColor),
                                  ),
                                  _InfoChip(
                                    label: 'Aired',
                                    value: data.aired_string ?? '-',
                                    color: Color(themeColor),
                                  ),
                                  _InfoChip(
                                    label: 'Episodes',
                                    value: data.episodes?.toString() ?? '-',
                                    color: Color(themeColor),
                                  ),
                                  _InfoChip(
                                    label: 'Status',
                                    value: data.status ?? '-',
                                    color: Color(themeColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if ((data.genres ?? []).isNotEmpty)
                                Text(
                                  (data.genres ?? []).join(', '),
                                  style: const TextStyle(color: Colors.white54),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Synopsis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.synopsis ?? '-',
                      style:
                          const TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
