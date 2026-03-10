import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Services/database_service.dart';
import 'package:vault/Services/firebase_database_impl.dart';

class PublicProfilePage extends StatefulWidget {
  final String handle;
  const PublicProfilePage({super.key, required this.handle});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  final DatabaseService _database = FirebaseDatabaseImpl();

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeProvider>(context).color;
    final primaryColor = Color(themeColor);

    return FutureBuilder<Map<String, dynamic>?>(
      future: _database.getPublicUserByHandle(widget.handle),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: const Color(0xFF121212),
            body: Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }

        if (data == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
              child: Text(
                'Profile not found',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final username = (data['username'] ?? 'User').toString();
        final handle = (data['handle'] ?? widget.handle).toString();

        final profile = (data['profile'] as Map?) ?? {};
        final photoUrl =
            (profile['photoUrl'] ?? data['imageURL'])?.toString();
        final bannerUrl = profile['bannerUrl']?.toString();

        final showcases = (data['showcases'] as Map?) ?? {};
        final enabled = (showcases['enabled'] as Map?) ?? {};
        final favEnabled = (enabled['favoriteCollection'] == true);
        final favKeys = (showcases['favoriteCollection'] is List)
            ? (showcases['favoriteCollection'] as List)
                .map((e) => e.toString())
                .toList()
            : <String>[];

        final library = (data['library'] is Map)
            ? Map<String, dynamic>.from(data['library'])
            : <String, dynamic>{};

        final favItems = <Map<String, dynamic>>[];
        for (final key in favKeys) {
          final raw = library[key];
          if (raw is Map) {
            favItems.add(Map<String, dynamic>.from(raw));
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _Header(
                  primaryColor: primaryColor,
                  bannerUrl: bannerUrl,
                  photoUrl: photoUrl,
                  username: username,
                  handle: handle,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SHOWCASES",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ShowcaseCard(
                        title: "Favorite Collection",
                        enabled: favEnabled,
                        child: favEnabled
                            ? _FavoriteGrid(items: favItems)
                            : const _DisabledShowcase(),
                      ),
                      const SizedBox(height: 12),
                      const _ShowcaseCard(
                        title: "Rare Achievements",
                        enabled: false,
                        child: _DisabledShowcase(),
                      ),
                      const SizedBox(height: 12),
                      const _ShowcaseCard(
                        title: "Screenshot Gallery",
                        enabled: false,
                        child: _DisabledShowcase(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final Color primaryColor;
  final String? bannerUrl;
  final String? photoUrl;
  final String username;
  final String handle;

  const _Header({
    required this.primaryColor,
    required this.bannerUrl,
    required this.photoUrl,
    required this.username,
    required this.handle,
  });

  @override
  Widget build(BuildContext context) {
    final banner = bannerUrl;
    final avatar = photoUrl;
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          Positioned.fill(
            child: banner == null
                ? Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1B1B1B), Color(0xFF121212)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: banner,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFF1B1B1B),
                    ),
                  ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF121212).withValues(alpha: 0.9),
                    const Color(0xFF121212).withValues(alpha: 0.65),
                    const Color(0xFF121212).withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 20,
            right: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.7),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xFF252525),
                    backgroundImage:
                        avatar == null ? null : CachedNetworkImageProvider(avatar),
                    child: avatar == null
                        ? const Icon(Icons.person, color: Colors.white54, size: 42)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "vault.app/$handle/profile",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  final String title;
  final bool enabled;
  final Widget child;

  const _ShowcaseCard({
    required this.title,
    required this.enabled,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: enabled ? Colors.white : Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: enabled
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: enabled
                        ? Colors.green.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  enabled ? "ACTIVE" : "INACTIVE",
                  style: TextStyle(
                    color: enabled ? Colors.greenAccent : Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DisabledShowcase extends StatelessWidget {
  const _DisabledShowcase();

  @override
  Widget build(BuildContext context) {
    return Text(
      "Bu vitrin şu an kapalı veya Steam bağlantısı gerektiriyor.",
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 12,
      ),
    );
  }
}

class _FavoriteGrid extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const _FavoriteGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        "Bu kullanıcı henüz favori vitrinini doldurmadı.",
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 12,
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.take(5).map((raw) {
        final title = (raw['title'] ?? '-').toString();
        final imageUrl = raw['imageURL']?.toString();
        return Container(
          width: 140,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            image: imageUrl == null
                ? null
                : DecorationImage(
                    image: CachedNetworkImageProvider(imageUrl),
                    fit: BoxFit.cover,
                  ),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF121212).withValues(alpha: 0.0),
                  const Color(0xFF121212).withValues(alpha: 0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

