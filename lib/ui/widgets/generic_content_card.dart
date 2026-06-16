import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault/data/model/base_content_model.dart';
import 'package:vault/Helper/content_type.dart';
import 'package:vault/Helper/rating_helper.dart';
import 'package:vault/Helper/ui_constants.dart';
import 'package:vault/Providers/library_provider.dart';

export 'package:vault/Helper/content_type.dart';

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
  final GlobalKey _menuAnchorKey = GlobalKey();

  Widget _buildImage(String imageUrl) {
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => Container(
          alignment: Alignment.center,
          color: Colors.grey[850],
          child: const Icon(
            Icons.image_not_supported_rounded,
            color: Colors.white38,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      placeholder: (context, url) => Container(
        color: Colors.grey[850],
        alignment: Alignment.center,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        alignment: Alignment.center,
        color: Colors.grey[850],
        child: const Icon(
          Icons.image_not_supported_rounded,
          color: Colors.white38,
        ),
      ),
    );
  }

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
      'id': widget.item.id,
      'type': _typePrefix(),
      'title': widget.item.title,
      'imageURL': widget.item.imageURL,
      'folder': folder,
    };
  }

  void _showContextMenu(
    BuildContext context,
    Offset position,
    LibraryProvider provider,
    bool inLibrary,
  ) {
    final id = widget.item.id;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: <PopupMenuEntry<dynamic>>[
        PopupMenuItem(
          child: const Text('Move to Favorites'),
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
          child: const Text('Move to Completed'),
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
          child: const Text('Move to Backlog'),
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
            child: Text('Move to $folder'),
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
            child: const Text('Create Custom Folder'),
            onTap: () {
              if (!mounted) return;
              final controller = TextEditingController();
              showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Create Folder'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Folder name'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: const Text('Create'),
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
            child: const Text(
              'Remove from Library',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              if (id == null) return;
              provider.removeFromLibrary(widget.type, id);
            },
          ),
        ],
      ],
    );
  }

  void _openContextMenuFromAnchor(
    BuildContext context,
    LibraryProvider provider,
    bool inLibrary,
  ) {
    final renderObject =
        _menuAnchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderObject == null) return;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final topLeft = renderObject.localToGlobal(Offset.zero, ancestor: overlay);
    final center = topLeft + Offset(renderObject.size.width, 0);
    _showContextMenu(context, center, provider, inLibrary);
  }

  @override
  Widget build(BuildContext context) {
    final double score = RatingHelper.getScore(widget.item);
    final bool hasRating = score > 0;
    final Color ratingColor =
        hasRating ? RatingHelper.getRatingColor(score) : Colors.white54;

    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, child) {
        final id = widget.item.id;
        final bool inLibrary =
            id == null ? false : libraryProvider.isInLibrary(widget.type, id);

        return Padding(
          padding: const EdgeInsets.all(UIConstants.contentCardPadding),
          child: MouseRegion(
            onEnter: (event) => isHovering.value = true,
            onExit: (event) => isHovering.value = false,
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => widget.detailPage),
                );
              },
              onLongPressStart: (details) {
                _showContextMenu(
                  context,
                  details.globalPosition,
                  libraryProvider,
                  inLibrary,
                );
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
                child: SizedBox(
                  width: 220,
                  height: 330,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: inLibrary
                                ? Color(widget.themeColor).withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.08),
                            width: inLibrary ? 2 : 1,
                          ),
                        ),
                        margin: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: widget.item.imageURL != null
                              ? _buildImage(widget.item.imageURL!)
                              : Container(
                                  alignment: Alignment.center,
                                  color: Colors.grey[850],
                                  child: const Icon(
                                    Icons.image_not_supported_rounded,
                                    color: Colors.white38,
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
                                  top: 10,
                                  right: 10,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      key: _menuAnchorKey,
                                      onTap: () => _openContextMenuFromAnchor(
                                        context,
                                        libraryProvider,
                                        inLibrary,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Ink(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.58),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color:
                                                Colors.white.withValues(alpha: 0.12),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.more_horiz,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(18),
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
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: hasRating
                                                ? ratingColor.withValues(alpha: 0.2)
                                                : Colors.white.withValues(alpha: 0.08),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: hasRating
                                                  ? ratingColor.withValues(alpha: 0.5)
                                                  : Colors.white.withValues(alpha: 0.12),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star_rounded,
                                                color: ratingColor,
                                                size: 14,
                                              ),
                                              if (!hasRating) ...[
                                                const SizedBox(width: 2),
                                                Icon(
                                                  Icons.question_mark_rounded,
                                                  color: ratingColor,
                                                  size: 12,
                                                ),
                                              ],
                                              const SizedBox(width: 4),
                                              if (hasRating)
                                                Text(
                                                  '${score.ceil()}',
                                                  style: TextStyle(
                                                    color: ratingColor,
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
          ),
        );
      },
    );
  }
}
