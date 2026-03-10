import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault/Data/Model/base_content_model.dart';
import 'package:vault/Helper/rating_helper.dart';
import 'package:vault/Helper/ui_constants.dart';
import 'package:vault/Helper/content_type.dart';
export 'package:vault/Helper/content_type.dart';
import 'package:vault/Providers/library_provider.dart';

class GenericContentCard extends StatefulWidget {
  final BaseContentModel item;
  final ContentType type;
  final int themeColor;
  final Widget detailPage;

  const GenericContentCard({
    Key? key,
    required this.item,
    required this.type,
    required this.themeColor,
    required this.detailPage,
  }) : super(key: key);

  @override
  State<GenericContentCard> createState() => _GenericContentCardState();
}

class _GenericContentCardState extends State<GenericContentCard> {
  final ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);

  String _typePrefix() {
    switch (widget.type) {
      case ContentType.games:
        return 'game';
      case ContentType.movies:
        return 'movie';
      case ContentType.series:
        return 'serie';
      case ContentType.books:
        return 'book';
      case ContentType.actors:
        return 'actor';
      case ContentType.anime:
        return 'anime';
    }
  }

  Map<String, dynamic> _createUnifiedItemMap({required String folder}) {
    return {
      "id": widget.item.id,
      "type": _typePrefix(),
      "title": widget.item.title,
      "imageURL": widget.item.imageURL,
      "folder": folder,
    };
  }

  void _showContextMenu(BuildContext context, Offset position,
      LibraryProvider provider, bool inLibrary) {
    final id = widget.item.id;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: <PopupMenuEntry<dynamic>>[
        PopupMenuItem(
          child: const Text("Move to Favorites"),
          onTap: () {
            if (id == null) return;
            provider.addOrUpdateItem(
              type: widget.type,
              id: id,
              title: widget.item.title,
              imageUrl: widget.item.imageURL,
              folder: 'favorites',
              extra: _createUnifiedItemMap(folder: 'favorites'),
            );
          },
        ),
        PopupMenuItem(
          child: const Text("Move to Completed"),
          onTap: () {
            if (id == null) return;
            provider.addOrUpdateItem(
              type: widget.type,
              id: id,
              title: widget.item.title,
              imageUrl: widget.item.imageURL,
              folder: 'completed',
              extra: _createUnifiedItemMap(folder: 'completed'),
            );
          },
        ),
        PopupMenuItem(
          child: const Text("Move to Backlog"),
          onTap: () {
            if (id == null) return;
            provider.addOrUpdateItem(
              type: widget.type,
              id: id,
              title: widget.item.title,
              imageUrl: widget.item.imageURL,
              folder: 'backlog',
              extra: _createUnifiedItemMap(folder: 'backlog'),
            );
          },
        ),
        if (provider.customFolders.isNotEmpty) const PopupMenuDivider(),
        for (final folder in provider.customFolders)
          PopupMenuItem(
            child: Text("Move to $folder"),
            onTap: () {
              if (id == null) return;
              provider.addOrUpdateItem(
                type: widget.type,
                id: id,
                title: widget.item.title,
                imageUrl: widget.item.imageURL,
                folder: folder,
                extra: _createUnifiedItemMap(folder: folder),
              );
            },
          ),
        if (provider.customFolders.length < 5) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            child: const Text("Create Custom Folder"),
            onTap: () {
              if (!mounted) return;
              final controller = TextEditingController();
              showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Create Folder"),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: "Folder name"),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: const Text("Create"),
                    ),
                  ],
                ),
              ).then((name) {
                if (!mounted) return;
                if (name != null) {
                  provider.addCustomFolder(name);
                }
              });
            },
          ),
        ],
        if (inLibrary) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            child: const Text("Remove from Library",
                style: TextStyle(color: Colors.red)),
            onTap: () {
              if (id == null) return;
              provider.removeFromLibrary(widget.type, id);
            },
          ),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double score = RatingHelper.getScore(widget.item);

    return Consumer<LibraryProvider>(
        builder: (context, libraryProvider, child) {
      final id = widget.item.id;
      bool inLibrary =
          id == null ? false : libraryProvider.isInLibrary(widget.type, id);

      return Padding(
        padding: const EdgeInsets.all(UIConstants.contentCardPadding),
        child: MouseRegion(
          onEnter: (event) => isHovering.value = true,
          onExit: (event) => isHovering.value = false,
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => widget.detailPage));
            },
            onSecondaryTapUp: (details) {
              _showContextMenu(
                  context, details.globalPosition, libraryProvider, inLibrary);
            },
            child: ValueListenableBuilder<bool>(
              valueListenable: isHovering,
              builder: (context, hovering, child) {
                return AnimatedScale(
                  scale: hovering ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: child,
                );
              },
              child: Stack(
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: inLibrary
                            ? Color(widget.themeColor).withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.08),
                        width: inLibrary ? 2 : 1,
                      ),
                    ),
                    margin: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        // 2:3 poster oranı
                        height: 360,
                        width: 240,
                        child: widget.item.imageURL != null
                            ? CachedNetworkImage(
                                imageUrl: widget.item.imageURL!,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[800]),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )
                            : Container(
                                alignment: Alignment.center,
                                color: Colors.grey[800],
                                child: const Icon(Icons.image_not_supported),
                              ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isHovering,
                      builder: (context, hovering, child) {
                        if (!hovering) return const SizedBox();
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                height: 72,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(16),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(0xFF000000)
                                          .withValues(alpha: 0.3),
                                      const Color(0xFF101010)
                                          .withValues(alpha: 0.85),
                                      const Color(0xFF000000)
                                          .withValues(alpha: 0.98),
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      widget.item.title ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (score > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              RatingHelper.getRatingColor(score)
                                                  .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: RatingHelper.getRatingColor(
                                                    score)
                                                .withValues(alpha: 0.5),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.star_rounded,
                                                color:
                                                    RatingHelper.getRatingColor(
                                                        score),
                                                size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${score.ceil()}",
                                              style: TextStyle(
                                                color:
                                                    RatingHelper.getRatingColor(
                                                        score),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
